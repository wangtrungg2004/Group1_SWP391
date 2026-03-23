package service;

import dao.SharedFileDAO;
import jakarta.servlet.ServletContext;
import jakarta.servlet.http.Part;
import model.SharedFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.sql.SQLException;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;
import java.util.UUID;

public class SharedFileService {

    private static final long MAX_FILE_SIZE = 15L * 1024 * 1024; // 15MB
    private static final Set<String> ALLOWED_MIME = new HashSet<>(Arrays.asList(
            "image/png", "image/jpeg", "application/pdf", "text/plain",
            "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
            "application/msword"));

    private final SharedFileDAO sharedFileDAO = new SharedFileDAO();

    public SharedFile saveUploadedPart(Part part, int userId, ServletContext context) throws IOException, SQLException {
        if (part == null || part.getSize() == 0) {
            return null;
        }

        if (part.getSize() > MAX_FILE_SIZE) {
            throw new IOException("File vượt quá giới hạn 15MB");
        }

        String contentType = part.getContentType();
        if (contentType != null && !ALLOWED_MIME.contains(contentType)) {
            throw new IOException("Định dạng file không được phép");
        }

        String originalName = Paths.get(part.getSubmittedFileName()).getFileName().toString();
        String storedName = UUID.randomUUID().toString();
        String extension = extractExtension(originalName);
        if (!extension.isEmpty()) {
            storedName = storedName + "." + extension;
        }

        Path uploadDir = Paths.get(context.getRealPath("/uploads"));
        Files.createDirectories(uploadDir);
        Path target = uploadDir.resolve(storedName); 
        part.write(target.toString());

        SharedFile file = new SharedFile();
        file.setOriginalName(originalName);
        file.setStoredName(storedName);
        file.setMimeType(contentType);
        file.setSizeBytes(part.getSize());
        file.setStoragePath("/uploads/" + storedName);
        file.setUploadedBy(userId);

        return sharedFileDAO.save(file);
    }

    private String extractExtension(String filename) {
        int idx = filename.lastIndexOf('.') + 1;
        if (idx > 0 && idx < filename.length()) {
            return filename.substring(idx);
        }
        return "";
    }
}
