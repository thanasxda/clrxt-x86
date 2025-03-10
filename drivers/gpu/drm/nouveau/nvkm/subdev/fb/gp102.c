/*
 * Copyright 2016 Red Hat Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL
 * THE COPYRIGHT HOLDER(S) OR AUTHOR(S) BE LIABLE FOR ANY CLAIM, DAMAGES OR
 * OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
 * ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 *
 * Authors: Ben Skeggs <bskeggs@redhat.com>
 */
#include "gf100.h"
#include "ram.h"

#include <engine/nvdec.h>

int
gp102_fb_vpr_scrub(struct nvkm_fb *fb)
{
	struct nvkm_subdev *subdev = &fb->subdev;
	struct nvkm_falcon_fw fw = {};
	int ret;

	ret = nvkm_falcon_fw_ctor_hs(&gm200_flcn_fw, "mem-unlock", subdev, NULL,
				     "nvdec/scrubber", 0, &subdev->device->nvdec[0]->falcon, &fw);
	if (ret)
		return ret;

	ret = nvkm_falcon_fw_boot(&fw, subdev, true, NULL, NULL, 0, 0x00000000);
	nvkm_falcon_fw_dtor(&fw);
	return ret;
}

bool
gp102_fb_vpr_scrub_required(struct nvkm_fb *fb)
{
	struct nvkm_device *device = fb->subdev.device;
	nvkm_wr32(device, 0x100cd0, 0x2);
	return (nvkm_rd32(device, 0x100cd0) & 0x00000010) != 0;
}

static const struct nvkm_fb_func
gp102_fb = {
	.dtor = gf100_fb_dtor,
	.oneinit = gf100_fb_oneinit,
	.init = gm200_fb_init,
	.init_remapper = gp100_fb_init_remapper,
	.init_page = gm200_fb_init_page,
	.sysmem.flush_page_init = gf100_fb_sysmem_flush_page_init,
	.vpr.scrub_required = gp102_fb_vpr_scrub_required,
	.vpr.scrub = gp102_fb_vpr_scrub,
	.ram_new = gp100_ram_new,
};

int
gp102_fb_new_(const struct nvkm_fb_func *func, struct nvkm_device *device,
	      enum nvkm_subdev_type type, int inst, struct nvkm_fb **pfb)
{
	int ret = gf100_fb_new_(func, device, type, inst, pfb);
	if (ret)
		return ret;

	nvkm_firmware_load_blob(&(*pfb)->subdev, "nvdec/scrubber", "", 0,
				&(*pfb)->vpr_scrubber);
	return 0;
}

int
gp102_fb_new(struct nvkm_device *device, enum nvkm_subdev_type type, int inst, struct nvkm_fb **pfb)
{
	return gp102_fb_new_(&gp102_fb, device, type, inst, pfb);
}

/*(DEBLOBBED)*/
