/**
 * Copyright (C) 2018 Vladimir Panteleev
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * Description:
 *
 * Tweak a sparse-image file to conform to Samsung's proprietary
 * format modifications.
 *
 * This allows creating sparse-image files directly flashable e.g. on
 * SM-N910H with Odin/Heimdall.
 */

module simg_samsungify;

import std.exception;
import std.mmfile;
import std.stdio;

struct SparseHeader
{
	uint magic = 0xed26ff3a;
    ushort major_version = 1;
    ushort minor_version = 0;
    ushort file_hdr_sz;
    ushort chunk_hdr_sz;
    uint blk_sz;
    uint total_blks;
    uint total_chunks;
    uint image_checksum;
}

struct ChunkHeader
{
    ubyte[2] chunk_type;
    ushort reserved1;
    uint chunk_sz;
    uint total_sz;
}

immutable uint[1] headerExtra = [0];
immutable uint[1] chunkExtra = [0x00007fcb];

void main(string[] args)
{
	enforce(args.length == 3, "Usage: simg_samsungify IN-FILE-NAME OUT-FILE-NAME");
	string inFileName = args[1];
	string outFileName = args[2];

	auto m = new MmFile(inFileName);
	enforce(m.length >= SparseHeader.sizeof, "Not enough bytes for header");
	auto p = cast(ubyte*)m[].ptr;
	auto pHeader = cast(SparseHeader*)p;
	enforce(pHeader.file_hdr_sz == SparseHeader.sizeof,
		"Wrong file header size (already samsung-ified?)");
	enforce(pHeader.chunk_hdr_sz == ChunkHeader.sizeof,
		"Wrong chunk header size (already samsung-ified?)");

	auto newHeader = *pHeader;
	newHeader.file_hdr_sz += headerExtra.sizeof;
	newHeader.chunk_hdr_sz += chunkExtra.sizeof;

	auto o = File(outFileName, "wb");
	o.rawWrite((&newHeader)[0..1]);
	o.rawWrite(headerExtra[]);

	auto end = p + m.length;
	p += pHeader.file_hdr_sz;
	while (p < end)
	{
		enforce(p + pHeader.chunk_hdr_sz <= end,
			"Not enough bytes for chunk header");
		auto pChunkHeader = cast(ChunkHeader*)p;
		//writeln(*pChunkHeader);
		enforce(p + pChunkHeader.total_sz <= end,
			"Not enough bytes for chunk");
		auto dataLength = pChunkHeader.total_sz - pHeader.chunk_hdr_sz;
		auto newChunkHeader = *pChunkHeader;
		newChunkHeader.total_sz += chunkExtra.sizeof;
		o.rawWrite((&newChunkHeader)[0..1]);
		o.rawWrite(chunkExtra);
		p += pHeader.chunk_hdr_sz;
		o.rawWrite(p[0..dataLength]);
		p += dataLength;
	}
}
