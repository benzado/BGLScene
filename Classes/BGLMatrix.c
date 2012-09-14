/*
 OpenGL matrix operations postmultiply onto the matrix stack.
 
 Matrices are stored in column-major order, since that's what glUniform() wants.
 
 That means: offset = row + column * row-count
 
 Indexes of a 4x4 Matrix are:
  0  4  8 12
  1  5  9 13
  2  6 10 14
  3  7 11 15
 
 Matrix multiplication code based on "Coding for NEON" blog post:
 http://blogs.arm.com/software-enablement/coding-for-neon-part-3-matrix-multiplication/
 */

#include "BGLMatrix.h"

#include <math.h>
#include <stdio.h>


#define BGLMatrixZero(m) memset(m, 0, 16*sizeof(float))
#define BGLMatrixAt(m,r,c) m[(r)+(c)*4]


static const BGLMatrix BGLMatrixIdentity = {
    1,0,0,0,
    0,1,0,0,
    0,0,1,0,
    0,0,0,1
};


void BGLMatrixPrint(BGLMatrix m)
{
    for (int r = 0; r < 4; r++) {
        printf("<%f, %f, %f, %f>\n",
               BGLMatrixAt(m,r,0),
               BGLMatrixAt(m,r,1),
               BGLMatrixAt(m,r,2),
               BGLMatrixAt(m,r,3));
    }
}


void BGLMatrixLoadIdentity(BGLMatrix m)
{
    BGLMatrixCopy(m, BGLMatrixIdentity);
}


void BGLMatrixMultiply(BGLMatrix m, const BGLMatrix a, const BGLMatrix b)
{
#ifdef __ARM_NEON__
    /*
     ARM calling convention places function arguments in registers r0-r3.
     That means r0 = &m, r1 = &a, r2 = &b.
     
     The NEON has thirty-two 64-bit registers, enough to load matrices A and B
     and also hold the resulting matrix.
     
     They can be addressed as:
        q0-q31 (128-bit quad word registers)
        d0-d63 (64-bit double word registers)
        d0[0], d0[1], d1[0], ... (32-bit word registers)
     
     One column of 32-bit numbers will fit into a single quad word register.
     A single vld1.32 instruction can load two columns of a matrix. We will
     fill the registers as follows:
     
        q0-q3    d0-d7        matrix B
        q4-q7    d8-d15        matrix A
        q8-q11    d16-d23        unused
        q12-q15    d24-d31        result
     
     We do this because the multiply instructions require that the scalar 
     argument be in the lower registers (or so it seems).
    
     Instead of grouping the instructions to compute q0, then q1, then q2, they
     are interleaved, so that the next instruction isn't dependent on the 
     previous instruction's result. That way, the processor can begin executing
     the next instruction before the previous one is complete.
     */
    __asm__ volatile 
    (
     // Load register contents from memory.
     
     "vld1.32 {d8-d11}, [%1]!    \n\t" // load 1st eight elements of A, advance r1
     "vld1.32 {d12-d15}, [%1]    \n\t" // load 2nd eight elements of A
     "vld1.32 {d0-d3}, [%2]!    \n\t" // load 1st eight elements of B, advance r2
     "vld1.32 {d4-d7}, [%2]        \n\t" // load 2nd eight elements of B

     // Multiply 1st column of Matrix A (q4) by the 1st value of each row
     // of Matrix B (d?[?]) and store in result columns (q12-q15).

     "vmul.f32    q12, q4, d0[0]    \n\t" // q12 := q4 * d0[0] or m[*,1] = a[*,1] x b[1,1]
     "vmul.f32    q13, q4, d2[0]    \n\t" // q13 := q4 * d2[0] or m[*,2] = a[*,1] x b[1,2]
     "vmul.f32    q14, q4, d4[0]    \n\t" // q14 := q4 * d4[0] or m[*,3] = a[*,1] x b[1,3]
     "vmul.f32    q15, q4, d6[0]    \n\t" // q15 := q4 * d6[0] or m[*,4] = a[*,1] x b[1,4]

     // Multiply 2nd column of Matrix A (q5) by the 2nd value of each row
     // of Matrix B (d?[?]) and add to result columns (q12-q15).
     
     "vmla.f32    q12, q5, d0[1]    \n\t" // q12 += q5 * d0[1] or m[*,1] += a[*,2] x b[2,1]
     "vmla.f32    q13, q5, d2[1]    \n\t" // q13 += q5 * d2[1] or m[*,2] += a[*,2] x b[2,2]
     "vmla.f32    q14, q5, d4[1]    \n\t" // q14 += q5 * d4[1] or m[*,3] += a[*,2] x b[2,3]
     "vmla.f32    q15, q5, d6[1]    \n\t" // q15 += q5 * d6[1] or m[*,4] += a[*,2] x b[2,4]

     // Multiply 3rd column of Matrix A (q6) by the 3rd value of each row
     // of Matrix B (d?[?]) and add to result columns (q12-q15).
     
     "vmla.f32    q12, q6, d1[0]    \n\t" // q12 += q6 * d1[0] or m[*,1] += a[*,3] x b[3,1]
     "vmla.f32    q13, q6, d3[0]    \n\t" // q13 += q6 * d3[0] or m[*,2] += a[*,3] x b[3,2]
     "vmla.f32    q14, q6, d5[0]    \n\t" // q14 += q6 * d5[0] or m[*,3] += a[*,3] x b[3,3]
     "vmla.f32    q15, q6, d7[0]    \n\t" // q15 += q6 * d7[0] or m[*,4] += a[*,3] x b[3,4]

     // Multiply 4th column of Matrix A (q7) by the 4th value of each row
     // of Matrix B (d?[?]) and add to result columns (q12-q15).
     
     "vmla.f32    q12, q7, d1[1]    \n\t" // q12 += q7 * d1[1] or m[*,1] += a[*,4] x b[4,1]
     "vmla.f32    q13, q7, d3[1]    \n\t" // q13 += q7 * d3[1] or m[*,2] += a[*,4] x b[4,2]
     "vmla.f32    q14, q7, d5[1]    \n\t" // q14 += q7 * d5[1] or m[*,3] += a[*,4] x b[4,3]
     "vmla.f32    q15, q7, d7[1]    \n\t" // q15 += q7 * d7[1] or m[*,4] += a[*,4] x b[4,4]
     
     // Write register contents back out to memory.
     
     "vst1.32 {d24-d27}, [%0]!    \n\t" // store 1st eight elements of result
     "vst1.32 {d28-d31}, [%0]    \n\t" // store 2nd eight elements of result 
     
     // Compiler Hint: output registers
     :
     // Compiler Hint: input registers
     : "r"(m), "r"(a), "r"(b)
     // Compiler Hint: clobbered registers
     : "q0","q1","q2","q3", "q4","q5","q6","q7", "q12","q13","q14","q15", "memory"
     );
#else
    BGLMatrix result;
    float *r;
    if (m == a || m == b) {
        r = result;
    } else {
        r = m;
    }
#define MULTIPLY(i,j) BGLMatrixAt(r,i,j) \
    = BGLMatrixAt(a,i,0)*BGLMatrixAt(b,0,j) \
    + BGLMatrixAt(a,i,1)*BGLMatrixAt(b,1,j) \
    + BGLMatrixAt(a,i,2)*BGLMatrixAt(b,2,j) \
    + BGLMatrixAt(a,i,3)*BGLMatrixAt(b,3,j);
    
    MULTIPLY(0,0)
    MULTIPLY(0,1)
    MULTIPLY(0,2)
    MULTIPLY(0,3)
    
    MULTIPLY(1,0)
    MULTIPLY(1,1)
    MULTIPLY(1,2)
    MULTIPLY(1,3)
    
    MULTIPLY(2,0)
    MULTIPLY(2,1)
    MULTIPLY(2,2)
    MULTIPLY(2,3)
    
    MULTIPLY(3,0)
    MULTIPLY(3,1)
    MULTIPLY(3,2)
    MULTIPLY(3,3)
    
#undef MULTIPLY
    if (r != m) {
        BGLMatrixCopy(m, r);
    }
#endif
}


BGLVector3 BGLMatrixApplyTransform(const BGLMatrix m, const BGLVector3 v)
{
    BGLVector3 result;
    float *ra = (float *)&result;
    const float *va = (const float *)&v;
    for (int i = 0; i < 3; i++) {
        ra[i] = 0;
        for (int j = 0; j < 3; j++) {
            ra[i] += BGLMatrixAt(m,i,j) * va[j];
        }
        ra[i] += BGLMatrixAt(m,i,3);
    }
    return result;
}



void BGLMatrixTranslate(BGLMatrix m, float x, float y, float z)
{
    BGLMatrix a, b;
    BGLMatrixCopy(a, m);
    memcpy(b, BGLMatrixIdentity, 12*sizeof(float));
    BGLMatrixAt(b,0,3) = x;
    BGLMatrixAt(b,1,3) = y;
    BGLMatrixAt(b,2,3) = z;
    BGLMatrixAt(b,3,3) = 1;
    BGLMatrixMultiply(m, b, a);
}


void BGLMatrixScale(BGLMatrix m, float x, float y, float z)
{
    BGLMatrix a, b;
    BGLMatrixCopy(a, m);
    BGLMatrixZero(b);
    BGLMatrixAt(b,0,0) = x;
    BGLMatrixAt(b,1,1) = y;
    BGLMatrixAt(b,2,2) = z;
    BGLMatrixAt(b,3,3) = 1;
    BGLMatrixMultiply(m, b, a);
}


void BGLMatrixRotate(BGLMatrix m, float degrees, float x, float y, float z)
{
#if DEBUG
    float length = sqrtf(x*x + y*y + z*z);
    if (length != 1.0f) {
        printf("BGLMatrixRotate WARNING: vector not normal |<%f,%f,%f>|=%f",
               x, y, z, length);
    }
#endif
    
    BGLMatrix a, b;
    BGLMatrixCopy(a, m);
    
    const float radians = degrees * (M_PI/180.0);
    
    const float s = sinf(radians);
    const float c = cosf(radians);
    
    const float one_minus_c = 1 - c;
    const float xs = x * s;
    const float ys = y * s;
    const float zs = z * s;
    
    BGLMatrixAt(b,0,0) = x*x*one_minus_c + c;
    BGLMatrixAt(b,0,1) = x*y*one_minus_c - zs;
    BGLMatrixAt(b,0,2) = x*z*one_minus_c + ys;
    BGLMatrixAt(b,0,3) = 0;
    
    BGLMatrixAt(b,1,0) = y*x*one_minus_c + zs;
    BGLMatrixAt(b,1,1) = y*y*one_minus_c + c;
    BGLMatrixAt(b,1,2) = y*z*one_minus_c - xs;
    BGLMatrixAt(b,1,3) = 0;

    BGLMatrixAt(b,2,0) = x*z*one_minus_c - ys;
    BGLMatrixAt(b,2,1) = y*z*one_minus_c + xs;
    BGLMatrixAt(b,2,2) = z*z*one_minus_c + c;
    BGLMatrixAt(b,2,3) = 0;

    BGLMatrixAt(b,3,0) = 0;
    BGLMatrixAt(b,3,1) = 0;
    BGLMatrixAt(b,3,2) = 0;
    BGLMatrixAt(b,3,3) = 1;
    
    BGLMatrixMultiply(m, b, a);
}


void BGLMatrixOrtho(BGLMatrix m, float left, float right, float bottom, float top, float zNear, float zFar)
{
    BGLMatrix a, b;
    BGLMatrixCopy(a, m);
    
    BGLMatrixZero(b);
    
    BGLMatrixAt(b,0,0) = 2.0f / (right - left);
    BGLMatrixAt(b,1,1) = 2.0f / (top - bottom);
    BGLMatrixAt(b,2,2) = -2.0f / (zFar - zNear);
    
    BGLMatrixAt(b,0,3) = - (right + left) / (right - left);
    BGLMatrixAt(b,1,3) = - (top + bottom) / (top - bottom);
    BGLMatrixAt(b,2,3) = - (zFar + zNear) / (zFar - zNear);
    
    BGLMatrixAt(b,3,3) = 1;

    BGLMatrixMultiply(m, b, a);
}


void BGLMatrixFrustum(BGLMatrix m, float left, float right, float bottom, float top, float zNear, float zFar)
{
    BGLMatrix a, b;
    BGLMatrixCopy(a, m);
    BGLMatrixZero(b);
    
    BGLMatrixAt(b,0,0) = 2 * zNear / (right - left);
    BGLMatrixAt(b,1,1) = 2 * zNear / (top - bottom);
    
    BGLMatrixAt(b,0,2) = (right + left) / (right - left);
    BGLMatrixAt(b,1,2) = (top + bottom) / (top - bottom);
    BGLMatrixAt(b,2,2) = (zFar + zNear) / (zFar - zNear);
    BGLMatrixAt(b,2,3) = -(2 * zFar * zNear) / (zFar - zNear);
    
    BGLMatrixAt(b,3,2) = -1;
    
    BGLMatrixMultiply(m, b, a);
}


void BGLMatrixPerspective(BGLMatrix m, float fovy, float aspect, float zNear, float zFar)
{
    const float radians = fovy * (M_PI_2 / 180.0f);
    const float deltaZ = zFar - zNear;
    const float sine = sinf(radians);

    if ((deltaZ == 0) || (sine == 0) || (aspect == 0)) {
#if DEBUG
        fputs("WARNING: BGLMatrixPerspective: illegal arguments", stderr);
#endif
        return;
    }
    
    const float cotangent = cosf(radians) / sine;
    
    BGLMatrix a, b;
    BGLMatrixCopy(a, m);
    BGLMatrixZero(b);
    BGLMatrixAt(b,0,0) = cotangent / aspect;
    BGLMatrixAt(b,1,1) = cotangent;
    BGLMatrixAt(b,2,2) = -(zFar + zNear) / deltaZ;
    BGLMatrixAt(b,2,3) = -1;
    BGLMatrixAt(b,3,2) = -2 * zNear * zFar / deltaZ;
    BGLMatrixAt(b,3,3) = 0;
    BGLMatrixMultiply(m, b, a);
}


void BGLMatrixLookAt(BGLMatrix m,
                     float eyeX, float eyeY, float eyeZ,
                     float centerX, float centerY, float centerZ,
                     float upX, float upY, float upZ)
{
    BGLVector3 forward = BGLVector3Make(centerX - eyeX,
                                        centerY - eyeY,
                                        centerZ - eyeZ);
    
    BGLVector3 up = BGLVector3Make(upX, upY, upZ);

    BGLVector3Normalize(&forward);

    BGLVector3 side = BGLVector3Cross(forward, up);
    BGLVector3Normalize(&side);
    
    up = BGLVector3Cross(side, forward);
    
    BGLMatrix a, b;
    BGLMatrixCopy(a, m);
    BGLMatrixZero(b);
    
    BGLMatrixAt(b,0,0) = side.x;
    BGLMatrixAt(b,0,1) = side.y;
    BGLMatrixAt(b,0,2) = side.z;
    
    BGLMatrixAt(b,1,0) = up.x;
    BGLMatrixAt(b,1,1) = up.y;
    BGLMatrixAt(b,1,2) = up.z;
    
    BGLMatrixAt(b,2,0) = -forward.x;
    BGLMatrixAt(b,2,1) = -forward.y;
    BGLMatrixAt(b,2,2) = -forward.z;
    
    BGLMatrixAt(b,3,3) = 1;
    
    BGLMatrixMultiply(m, b, a);
    BGLMatrixTranslate(m, -eyeX, -eyeY, -eyeZ);
}


int BGLMatrixInvert(BGLMatrix r, const BGLMatrix m)
{
    // Adapted from mesa project code.
    
    BGLMatrix inv;
    
    inv[0] = m[5]*m[10]*m[15] - m[5]*m[11]*m[14] - m[9]*m[6]*m[15] + m[9]*m[7]*m[14] + m[13]*m[6]*m[11] - m[13]*m[7]*m[10];
    inv[4] =  -m[4]*m[10]*m[15] + m[4]*m[11]*m[14] + m[8]*m[6]*m[15] - m[8]*m[7]*m[14] - m[12]*m[6]*m[11] + m[12]*m[7]*m[10];
    inv[8] =   m[4]*m[9]*m[15] - m[4]*m[11]*m[13] - m[8]*m[5]*m[15] + m[8]*m[7]*m[13] + m[12]*m[5]*m[11] - m[12]*m[7]*m[9];
    inv[12] = -m[4]*m[9]*m[14] + m[4]*m[10]*m[13] + m[8]*m[5]*m[14]    - m[8]*m[6]*m[13] - m[12]*m[5]*m[10] + m[12]*m[6]*m[9];
    inv[1] =  -m[1]*m[10]*m[15] + m[1]*m[11]*m[14] + m[9]*m[2]*m[15] - m[9]*m[3]*m[14] - m[13]*m[2]*m[11] + m[13]*m[3]*m[10];
    inv[5] =   m[0]*m[10]*m[15] - m[0]*m[11]*m[14] - m[8]*m[2]*m[15] + m[8]*m[3]*m[14] + m[12]*m[2]*m[11] - m[12]*m[3]*m[10];
    inv[9] =  -m[0]*m[9]*m[15] + m[0]*m[11]*m[13] + m[8]*m[1]*m[15] - m[8]*m[3]*m[13] - m[12]*m[1]*m[11] + m[12]*m[3]*m[9];
    inv[13] =  m[0]*m[9]*m[14] - m[0]*m[10]*m[13] - m[8]*m[1]*m[14] + m[8]*m[2]*m[13] + m[12]*m[1]*m[10] - m[12]*m[2]*m[9];
    inv[2] =   m[1]*m[6]*m[15] - m[1]*m[7]*m[14] - m[5]*m[2]*m[15] + m[5]*m[3]*m[14] + m[13]*m[2]*m[7] - m[13]*m[3]*m[6];
    inv[6] =  -m[0]*m[6]*m[15] + m[0]*m[7]*m[14] + m[4]*m[2]*m[15] - m[4]*m[3]*m[14] - m[12]*m[2]*m[7] + m[12]*m[3]*m[6];
    inv[10] =  m[0]*m[5]*m[15] - m[0]*m[7]*m[13] - m[4]*m[1]*m[15] + m[4]*m[3]*m[13] + m[12]*m[1]*m[7] - m[12]*m[3]*m[5];
    inv[14] = -m[0]*m[5]*m[14] + m[0]*m[6]*m[13] + m[4]*m[1]*m[14] - m[4]*m[2]*m[13] - m[12]*m[1]*m[6] + m[12]*m[2]*m[5];
    inv[3] =  -m[1]*m[6]*m[11] + m[1]*m[7]*m[10] + m[5]*m[2]*m[11] - m[5]*m[3]*m[10] - m[9]*m[2]*m[7] + m[9]*m[3]*m[6];
    inv[7] =   m[0]*m[6]*m[11] - m[0]*m[7]*m[10] - m[4]*m[2]*m[11] + m[4]*m[3]*m[10] + m[8]*m[2]*m[7] - m[8]*m[3]*m[6];
    inv[11] = -m[0]*m[5]*m[11] + m[0]*m[7]*m[9] + m[4]*m[1]*m[11] - m[4]*m[3]*m[9] - m[8]*m[1]*m[7] + m[8]*m[3]*m[5];
    inv[15] =  m[0]*m[5]*m[10] - m[0]*m[6]*m[9] - m[4]*m[1]*m[10] + m[4]*m[2]*m[9] + m[8]*m[1]*m[6] - m[8]*m[2]*m[5];
    
    float det = m[0]*inv[0] + m[1]*inv[4] + m[2]*inv[8] + m[3]*inv[12];

    if (det == 0) return 0;
    
    det = 1.0f / det;
    
    for (int i = 0; i < 16; i++) {
        r[i] = inv[i] * det;
    }
    
    return 1;
}


#define BGLMatrix3At(m,r,c) m[(r)+(c)*3]


float BGLMatrix3Determinant(BGLMatrix3 m)
{
    return (m[0] * (m[4]*m[8] - m[7]*m[5]) +
            m[3] * (m[7]*m[2] - m[8]*m[1]) +
            m[6] * (m[1]*m[5] - m[4]*m[2]) );
}


void BGLMatrix3Invert(BGLMatrix3 m)
{
    // http://en.wikipedia.org/wiki/Invertible_matrix#Inversion_of_3.C3.973_matrices
    // a0 b3 c6
    // d1 e4 f7
    // g2 h5 k8

    float z = 1.0f / BGLMatrix3Determinant(m);
    
    BGLMatrix3 r;
    memcpy(r, m, 9*sizeof(float));
    
    m[0] = z * (m[4]*m[8] - m[7]*m[5]);
    m[1] = z * (m[7]*m[2] - m[1]*m[8]);
    m[2] = z * (m[1]*m[5] - m[4]*m[2]);
    
    m[3] = z * (m[6]*m[5] - m[3]*m[8]);
    m[4] = z * (m[0]*m[8] - m[6]*m[2]);
    m[5] = z * (m[3]*m[2] - m[0]*m[5]);
    
    m[6] = z * (m[3]*m[7] - m[6]*m[4]);
    m[7] = z * (m[6]*m[1] - m[0]*m[7]);
    m[8] = z * (m[0]*m[4] - m[3]*m[1]);
}


void BGLMatrix3Transpose(BGLMatrix3 m)
{
    // 0 3 6      0 1 2
    // 1 4 7  to  3 4 5
    // 2 5 8      6 7 8
    
    float t;
    
    t = m[1]; m[1] = m[3]; m[3] = t;
    t = m[2]; m[2] = m[6]; m[6] = t;
    t = m[5]; m[5] = m[7]; m[5] = t;
}


void BGLMatrix3ComputeNormalMatrix(BGLMatrix3 normalMatrix, BGLMatrix transformationMatrix)
{
    // Let M be upper left 3x3 of transformationMatrix
    // Return the transpose of the inverse!
    
    // 0  4  8
    // 1  5  9
    // 2  6 10
    
    normalMatrix[0] = transformationMatrix[0];
    normalMatrix[1] = transformationMatrix[1];
    normalMatrix[2] = transformationMatrix[2];

    normalMatrix[3] = transformationMatrix[4];
    normalMatrix[4] = transformationMatrix[5];
    normalMatrix[5] = transformationMatrix[6];
    
    normalMatrix[6] = transformationMatrix[8];
    normalMatrix[7] = transformationMatrix[9];
    normalMatrix[8] = transformationMatrix[10];
    
    BGLMatrix3Invert(normalMatrix);
    BGLMatrix3Transpose(normalMatrix);
}
