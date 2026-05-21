/// Regression tests for MAXSTRING on large binary stream import.
/// zpm "isc.json test -only -DUnitTest.Case=UnitTest.isc.json.importLargeStream"
Class UnitTest.isc.json.importLargeStream Extends %UnitTest.TestCase
{

/// Verify that %JSONImport handles a BinaryStream field whose base64 payload exceeds
/// ObjectScript's ~3.6 MB MAXSTRING limit. Decoding the entire string in one call
/// raises <MAXSTRING>; the import must instead process the field in chunks and
/// round-trip the decoded content without data loss.
Method TestImportLargeBinaryStream()
{
    // ~3 MB of raw bytes; base64 expands to ~4.2 MB — safely above the 3.6 MB MAXSTRING ceiling.
    Set chunkSize = 32768
    Set totalBytes = 3 * 1024 * 1024

    // Build a raw binary stream filled with a repeating byte pattern.
    Set rawStream = ##class(%Stream.TmpBinary).%New()
    Set chunk = ""
    For i = 1:1:chunkSize {
        Set chunk = chunk _ $char(i # 256)
    }
    Set written = 0
    While written < totalBytes {
        Set remaining = totalBytes - written
        Set writeLen = $select(remaining < chunkSize : remaining, 1 : chunkSize)
        Do rawStream.Write($extract(chunk, 1, writeLen))
        Set written = written + writeLen
    }
    Do rawStream.Rewind()

    // Base64-encode in chunks whose size is a multiple of 3 to keep base64 group boundaries
    // aligned. IRIS also inserts CRLF every 76 chars by default, which the generator strips
    // during import. Real REST clients send base64 without newlines in JSON, so the generator
    // handles both.
    Set b64Stream = ##class(%Stream.TmpCharacter).%New()
    While 'rawStream.AtEnd {
        Do b64Stream.Write($system.Encryption.Base64Encode(rawStream.Read(57600)))
    }
    Do b64Stream.Rewind()

    // Use %Set(...,"stream") so %DynamicObject reads from the stream rather than
    // requiring the full string to exist as a scalar.
    Set dobj = ##class(%DynamicObject).%New()
    Set dobj.Name = "LargeStreamTest"
    Do dobj.%Set("BinaryStream", b64Stream, "stream")

    // Wrap in Try/Catch: a naive single-call decode raises <MAXSTRING> as an
    // ObjectScript exception, bypassing %JSONImport's normal %Status return.
    Set inst = ##class(UnitTest.isc.json.sample.generalPersistent).%New()
    Set sc = $$$OK
    Try {
        Set sc = inst.%JSONImport(dobj)
    } Catch ex {
        Set sc = ex.AsStatus()
    }
    Do $$$AssertStatusOK(sc, "Import of large binary stream should succeed without <MAXSTRING>")

    // Verify round-trip: byte count and content must match the original.
    // Read both streams in parallel and compare chunk by chunk to avoid accumulating
    // a 3 MB string in memory.
    Do rawStream.Rewind()
    Do inst.BinaryStream.Rewind()
    Set chunkMismatch = 0
    While 'rawStream.AtEnd {
        Set rawChunk     = rawStream.Read(57600)
        Set decodedChunk = inst.BinaryStream.Read(57600)
        If rawChunk '= decodedChunk Set chunkMismatch = 1  Quit
    }
    Do $$$AssertEquals(chunkMismatch, 0, "Decoded stream content must match original byte-for-byte")
    Do $$$AssertTrue(inst.BinaryStream.AtEnd, "Decoded stream must not contain surplus bytes beyond the original")
}

/// Verify that the base64 remainder-flush path works correctly when the payload size
/// is not divisible by 3. In that case the final base64 group is 2 or 3 chars with
/// padding, and the flush code path (b64buf'="") must be exercised to decode it.
Method TestImportLargeBinaryStreamNonMultipleOf3()
{
    // 3 MB + 7 bytes — not divisible by 3, so the final b64 group requires the flush path.
    Set chunkSize = 32768
    Set totalBytes = 3 * 1024 * 1024 + 7

    Set rawStream = ##class(%Stream.TmpBinary).%New()
    Set chunk = ""
    For i = 1:1:chunkSize {
        Set chunk = chunk _ $char(i # 256)
    }
    Set written = 0
    While written < totalBytes {
        Set remaining = totalBytes - written
        Set writeLen = $select(remaining < chunkSize : remaining, 1 : chunkSize)
        Do rawStream.Write($extract(chunk, 1, writeLen))
        Set written = written + writeLen
    }
    Do rawStream.Rewind()

    Set b64Stream = ##class(%Stream.TmpCharacter).%New()
    While 'rawStream.AtEnd {
        Do b64Stream.Write($system.Encryption.Base64Encode(rawStream.Read(57600)))
    }
    Do b64Stream.Rewind()

    Set dobj = ##class(%DynamicObject).%New()
    Set dobj.Name = "LargeStreamTest2"
    Do dobj.%Set("BinaryStream", b64Stream, "stream")

    Set inst = ##class(UnitTest.isc.json.sample.generalPersistent).%New()
    Set sc = $$$OK
    Try {
        Set sc = inst.%JSONImport(dobj)
    } Catch ex {
        Set sc = ex.AsStatus()
    }
    Do $$$AssertStatusOK(sc, "Import of large binary stream (non-multiple-of-3) should succeed without <MAXSTRING>")

    Do rawStream.Rewind()
    Do inst.BinaryStream.Rewind()
    Set chunkMismatch = 0
    While 'rawStream.AtEnd {
        Set rawChunk     = rawStream.Read(57600)
        Set decodedChunk = inst.BinaryStream.Read(57600)
        If rawChunk '= decodedChunk Set chunkMismatch = 1  Quit
    }
    Do $$$AssertEquals(chunkMismatch, 0, "Decoded stream content must match original byte-for-byte (non-multiple-of-3)")
    Do $$$AssertTrue(inst.BinaryStream.AtEnd, "Decoded stream must not contain surplus bytes beyond the original (non-multiple-of-3)")
}

}
