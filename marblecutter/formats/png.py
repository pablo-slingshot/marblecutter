# coding=utf-8
from __future__ import absolute_import

from io import BytesIO

from PIL import Image

from .. import _isimage

CONTENT_TYPE = "image/png"


def PNG(paletted=False):

    def _format(pixels, data_format, sources):
        if not _isimage(data_format):
            raise Exception("Must be an image format")

        out = BytesIO()
        im = Image.fromarray(pixels.data, data_format.upper())

        if paletted:
            im = im.convert("P", dither="NONE")

        im.save(out, "png")

        return (CONTENT_TYPE, out.getvalue())

    return _format
