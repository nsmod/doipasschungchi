import Foundation

enum ZipWriter {
    static func makeZip(files: [(name: String, data: Data)], to url: URL) throws {
        var out = Data(); var central = Data(); var offsets: [UInt32] = []
        for f in files {
            let name = Data(f.name.utf8); let crc = CRC32.compute(f.data); offsets.append(UInt32(out.count))
            out.appendLE(UInt32(0x04034b50)); out.appendLE(UInt16(20)); out.appendLE(UInt16(0)); out.appendLE(UInt16(0)); out.appendLE(UInt16(0)); out.appendLE(UInt16(0)); out.appendLE(crc); out.appendLE(UInt32(f.data.count)); out.appendLE(UInt32(f.data.count)); out.appendLE(UInt16(name.count)); out.appendLE(UInt16(0)); out.append(name); out.append(f.data)
            central.appendLE(UInt32(0x02014b50)); central.appendLE(UInt16(20)); central.appendLE(UInt16(20)); central.appendLE(UInt16(0)); central.appendLE(UInt16(0)); central.appendLE(UInt16(0)); central.appendLE(UInt16(0)); central.appendLE(crc); central.appendLE(UInt32(f.data.count)); central.appendLE(UInt32(f.data.count)); central.appendLE(UInt16(name.count)); central.appendLE(UInt16(0)); central.appendLE(UInt16(0)); central.appendLE(UInt16(0)); central.appendLE(UInt16(0)); central.appendLE(UInt32(0)); central.appendLE(offsets.last!); central.append(name)
        }
        let centralOffset = UInt32(out.count); out.append(central)
        out.appendLE(UInt32(0x06054b50)); out.appendLE(UInt16(0)); out.appendLE(UInt16(0)); out.appendLE(UInt16(files.count)); out.appendLE(UInt16(files.count)); out.appendLE(UInt32(central.count)); out.appendLE(centralOffset); out.appendLE(UInt16(0))
        try out.write(to: url, options: .atomic)
    }
}

private enum CRC32 {
    static func compute(_ data: Data) -> UInt32 { var crc: UInt32 = 0xffffffff; for b in data { crc ^= UInt32(b); for _ in 0..<8 { crc = (crc & 1) != 0 ? (crc >> 1) ^ 0xedb88320 : crc >> 1 } }; return crc ^ 0xffffffff }
}
private extension Data {
    mutating func appendLE<T: FixedWidthInteger>(_ value: T) { var v = value.littleEndian; Swift.withUnsafeBytes(of: &v) { append(contentsOf: $0) } }
}
