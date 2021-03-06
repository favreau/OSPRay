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

#undef NDEBUG

// ospray
#include "Slices.h"
#include "ospray/common/Data.h"
#include "ospray/common/Model.h"
// ispc-generated files
#include "Slices_ispc.h"

namespace ospray {

  Slices::Slices()
  {
    this->ispcEquivalent = ispc::Slices_create(this);
  }

  void Slices::finalize(Model *model) 
  {
    planesData = getParamData("planes", NULL);
    volume     = (Volume *)getParamObject("volume", NULL);

    Assert(planesData);
    Assert(volume);

    numPlanes = planesData->numItems;
    planes    = (const vec4f*)planesData->data;

    ispc::Slices_set(getIE(), model->getIE(), numPlanes, (ispc::vec4f*)planes, volume->getIE());
  }

  OSP_REGISTER_GEOMETRY(Slices, slices);

} // ::ospray
