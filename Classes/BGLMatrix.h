/*
 A matrix transformation library, to fill the gap left by OpenGL ES 2.0.
 */

#include <string.h>
#include <math.h>


#pragma mark BGLVector3


typedef struct {
    float x;
    float y;
    float z;
} BGLVector3;


static inline BGLVector3 BGLVector3Make(const float x, const float y, const float z)
{
    BGLVector3 v;
    v.x = x; v.y = y; v.z = z;
    return v;
}


static inline float BGLVector3Length(const BGLVector3 v)
{
    return sqrtf((v.x * v.x) + (v.y * v.y) + (v.z * v.z));
}


static inline void BGLVector3Normalize(BGLVector3 *pv)
{
    const float r = BGLVector3Length(*pv);
    if (r == 0) return;
    pv->x /= r;
    pv->y /= r;
    pv->z /= r;
}


static inline BGLVector3 BGLVector3Add(const BGLVector3 a, const BGLVector3 b)
{
    return BGLVector3Make(a.x + b.x, a.y + b.y, a.z + b.z);
}


static inline BGLVector3 BGLVector3Multiply(const BGLVector3 a, const BGLVector3 b)
{
    return BGLVector3Make(a.x * b.x, a.y * b.y, a.z * b.z);
}


static inline BGLVector3 BGLVector3Cross(const BGLVector3 a, const BGLVector3 b)
{
    return BGLVector3Make(a.y*b.z - a.z*b.y,
                          a.z*b.x - a.x*b.z, 
                          a.x*b.y - a.y*b.x);
}


static inline float BGLVector3Dot(const BGLVector3 a, const BGLVector3 b)
{
    return a.x*b.x + a.y*b.y + a.z*b.z;
}


#pragma mark BGLVector2


typedef struct {
    float x;
    float y;
} BGLVector2;


static inline BGLVector2 BGLVector2Make(const float x, const float y)
{
    BGLVector2 v;
    v.x = x; v.y = y;
    return v;
}


static inline float BGLVector2Length(const BGLVector2 v)
{
    return sqrtf((v.x * v.x) + (v.y * v.y));
}


#pragma mark BGLMatrix


typedef float BGLMatrix[16];


static const int kBGLMatrixOffsetTranslateX = 12;
static const int kBGLMatrixOffsetTranslateY = 13;
static const int kBGLMatrixOffsetTranslateZ = 14;
static const int kBGLMatrixOffsetScaleX = 0;
static const int kBGLMatrixOffsetScaleY = 5;
static const int kBGLMatrixOffsetScaleZ = 10;


static inline void BGLMatrixCopy(BGLMatrix to, const BGLMatrix from)
{
    memcpy(to, from, 16*sizeof(float));
}


void BGLMatrixPrint(BGLMatrix m);
void BGLMatrixLoadIdentity(BGLMatrix m);
void BGLMatrixMultiply(BGLMatrix m, const BGLMatrix a, const BGLMatrix b);
void BGLMatrixTranslate(BGLMatrix m, float x, float y, float z);
void BGLMatrixScale(BGLMatrix m, float x, float y, float z);
void BGLMatrixRotate(BGLMatrix m, float degrees, float x, float y, float z);
void BGLMatrixOrtho(BGLMatrix m, float left, float right, float bottom, float top, float zNear, float zFar);
void BGLMatrixFrustum(BGLMatrix m, float left, float right, float bottom, float top, float zNear, float zFar);
void BGLMatrixPerspective(BGLMatrix m, float fovy, float aspect, float zNear, float zFar);
void BGLMatrixLookAt(BGLMatrix m,
                     float eyeX, float eyeY, float eyeZ,
                     float centerX, float centerY, float centerZ,
                     float upX, float upY, float upZ);
int BGLMatrixInvert(BGLMatrix r, const BGLMatrix m);


#pragma mark BGLMatrix3


typedef float BGLMatrix3[9];


void BGLMatrix3ComputeNormalMatrix(BGLMatrix3 normalMatrix, BGLMatrix transformationMatrix);


#pragma mark synergy


BGLVector3 BGLMatrixApplyTransform(const BGLMatrix m, const BGLVector3 v);
