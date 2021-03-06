// ======================================================================== //
// Copyright 2009-2016 Intel Corporation                                    //
//                                                                          //
// Licensed under the Apache License, Version 2.0 (the "License");          //
// you may not use this file except in compliance with the License.         //
// You may obtain a copy of the License at                                  //
//                                                                          //
//     http://www.apache.org/licenses/LICENSE-2.0                           //
//                                                                          //
// Unless required by applicable law or agreed to in writing, software      //
// distributed under the License is distributed on an "AS IS" BASIS,        //
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. //
// See the License for the specific language governing permissions and      //
// limitations under the License.                                           //
// ======================================================================== //

#include "PerspectiveCamera.ih"
#include "ospray/math/sampling.ih"

void PerspectiveCamera_initRay(uniform Camera *uniform _self,
                               varying Ray &ray,
                               const varying CameraSample &sample)
{
  uniform PerspectiveCamera *uniform self =
    (uniform PerspectiveCamera *uniform)_self;

  uniform vec2f& imageStart = self->imageStart;
  uniform vec2f& imageEnd   = self->imageEnd;

  vec3f org = self->org;
  vec3f dir = self->dir_00
    + ((imageStart.x * self->dir_du)
       + (sample.screen.x * (self->dir_du * (imageEnd.x - imageStart.x))))
    + ((imageStart.y * self->dir_dv)
       + (sample.screen.y * (self->dir_dv * (imageEnd.y - imageStart.y))));

  if (self->super.doesDOF) {
    const vec3f llp = uniformSampleDisk(self->scaledAperture, sample.lens);
    // transform local lens point to focal plane (dir_XX are prescaled in this case)
    const vec3f lp = (llp.x * self->dir_du)
         + ((llp.y * self->aspect) * self->dir_dv);
    org = org + lp;
    dir = dir - lp;
  }

  setRay(ray, org, normalize(dir), self->super.nearClip, infinity);
}

/*! create a new ispc-side version of a perspectivecamera - with given
    pointer to the c-class version - and return both class pointer and
    pointer to internal data back via the supplied reference
    parameters */
export void *uniform PerspectiveCamera_create(void *uniform cppE)
{
  uniform PerspectiveCamera *uniform self
    = uniform new uniform PerspectiveCamera;
  self->super.cppEquivalent = cppE;
  self->super.initRay = PerspectiveCamera_initRay;
  self->super.doesDOF = false;
  return self;
}

export void PerspectiveCamera_set(void *uniform _self,
                                  const uniform vec3f &org,
                                  const uniform vec3f &dir_00,
                                  const uniform vec3f &dir_du,
                                  const uniform vec3f &dir_dv,
                                  const uniform vec2f &imageStart,
                                  const uniform vec2f &imageEnd,
                                  const uniform float scaledAperture,
                                  const uniform float aspect,
                                  const uniform float nearClip)
{
  uniform PerspectiveCamera *uniform self
    = (uniform PerspectiveCamera *uniform)_self;
  self->org    = org;
  self->dir_00 = dir_00;
  self->dir_du = dir_du;
  self->dir_dv = dir_dv;
  self->imageStart = imageStart;
  self->imageEnd   = imageEnd;
  self->super.nearClip = nearClip;
  self->scaledAperture = scaledAperture;
  self->super.doesDOF = scaledAperture > 0.f;
  self->aspect = aspect;
}
