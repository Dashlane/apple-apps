import Foundation

public struct DocumentTypeSupport {

  public static func includes(_ type: String) -> Bool {
    return supportedTypes.contains(type.lowercased())
  }

  public static var supportedTypes: Set<String> {
    return Set([
      "3gp",
      "7z",
      "aac",
      "avi",
      "azw3",
      "bmp",
      "csv",
      "db",
      "doc",
      "docx",
      "flac",
      "gif",
      "gz",
      "heic",
      "heif",
      "jpeg",
      "jpg",
      "key",
      "license",
      "m4a",
      "mkv",
      "mov",
      "mp3",
      "mp4",
      "mpg",
      "odg",
      "odp",
      "ods",
      "odt",
      "ogg",
      "pdf",
      "png",
      "ppt",
      "pptx",
      "rar",
      "raw",
      "tar",
      "tiff",
      "txt",
      "wav",
      "webm",
      "wmv",
      "xls",
      "xlsx",
      "zip",
    ])
  }
}
