"""Obtém apenas os templates Windows do arquivo oficial de exportação Godot.

O pacote completo tem mais de 1 GB. Requisições HTTP Range leem seu índice ZIP
e os dois executáveis necessários, sem instalar ou alterar o Godot do usuário.
"""

from pathlib import Path
import struct
import urllib.request
import zlib

VERSION = "4.7.2"
URL = (
    "https://godot-releases.nbg1.your-objectstorage.com/"
    f"{VERSION}-stable/Godot_v{VERSION}-stable_export_templates.tpz"
)
DESTINATION = Path(__file__).resolve().parents[1] / ".tools" / "templates"
TARGETS = {"windows_debug_x86_64.exe", "windows_release_x86_64.exe"}


def read_range(start: int | None, end: int | None = None) -> bytes:
    byte_range = "bytes=-65536" if start is None else f"bytes={start}-{end}"
    request = urllib.request.Request(URL, headers={"Range": byte_range})
    with urllib.request.urlopen(request, timeout=90) as response:
        if response.status != 206:
            raise RuntimeError("Servidor não aceitou leitura parcial; download interrompido.")
        result = response.read()
    expected = 65536 if start is None else end - start + 1
    if len(result) != expected:
        raise RuntimeError("Resposta parcial incompleta.")
    return result


def main() -> None:
    tail = read_range(None)
    end_record = tail.rfind(b"PK\x05\x06")
    if end_record < 0:
        raise RuntimeError("Índice ZIP não encontrado.")
    record = struct.unpack_from("<4s4H2IH", tail, end_record)
    directory_size, directory_offset = record[5], record[6]
    directory = read_range(directory_offset, directory_offset + directory_size - 1)
    cursor = 0
    found = set()
    DESTINATION.mkdir(parents=True, exist_ok=True)
    while cursor < len(directory):
        entry = struct.unpack_from("<4s6H3I5H2I", directory, cursor)
        if entry[0] != b"PK\x01\x02":
            raise RuntimeError("Entrada inválida no índice ZIP.")
        name_length, extra_length, comment_length = entry[10:13]
        name = directory[cursor + 46:cursor + 46 + name_length].decode("utf-8")
        cursor += 46 + name_length + extra_length + comment_length
        filename = name.rsplit("/", 1)[-1]
        if filename not in TARGETS:
            continue
        compression, checksum, compressed_size, size, offset = (
            entry[4], entry[7], entry[8], entry[9], entry[16]
        )
        print(f"Obtendo {filename}: {compressed_size / 1024**2:.1f} MiB...", flush=True)
        header = struct.unpack("<4s5H3I2H", read_range(offset, offset + 29))
        if header[0] != b"PK\x03\x04":
            raise RuntimeError("Cabeçalho local inválido.")
        payload_offset = offset + 30 + header[9] + header[10]
        payload = read_range(payload_offset, payload_offset + compressed_size - 1)
        if compression == 8:
            executable = zlib.decompress(payload, -15)
        elif compression == 0:
            executable = payload
        else:
            raise RuntimeError(f"Compressão ZIP não suportada: {compression}")
        if len(executable) != size or zlib.crc32(executable) != checksum:
            raise RuntimeError(f"Falha de integridade em {filename}.")
        (DESTINATION / filename).write_bytes(executable)
        found.add(filename)
        print(f"Salvo: {DESTINATION / filename}; tamanho e CRC32 conferidos.", flush=True)
    if found != TARGETS:
        raise RuntimeError("O pacote não contém todos os templates esperados.")


if __name__ == "__main__":
    main()
