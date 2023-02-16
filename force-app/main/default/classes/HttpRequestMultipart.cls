/**
 * A class for building multipart/form-data HTTP requests.
 * Based on: https://www.w3.org/Protocols/rfc1341/7_2_Multipart.html
 *
 * Created by William Watson on 13/12/2022.
 */
public with sharing class HttpRequestMultipart {

    // Constants used for building the multipart request
    private final static String BOUNDARY = 'gc0p4Jq0M2Yt08jU534c0p';
    private final static String HYPHENS = '--';
    private final static String CRLF = '\r\n';

    // The HttpRequest object that will be used to send the multipart request
    @TestVisible private HttpRequest httpRequest;

    // The body of the multipart request, encoded as a hexadecimal string
    @TestVisible private String multipartBodyHex = '';

    /**
     * Constructs a new instance of the HttpRequestMultipart class.
     * Sets the Content-Type header to "multipart/mixed" with the boundary set to a constant value.
     */
    public HttpRequestMultipart()
    {
        this.httpRequest = new HttpRequest();
        this.httpRequest.setHeader('Content-Type', 'multipart/mixed; boundary=' + BOUNDARY);
    }

    /**
     * Sets the HTTP method for the request.
     * @param httpMethod The HTTP method to use (e.g. "GET", "POST", "PUT").
     * @return This HttpRequestMultipart instance, for method chaining.
     */
    public HttpRequestMultipart setHttpMethod(String httpMethod)
    {
        this.httpRequest.setMethod(httpMethod);
        return this;
    }

    /**
     * Adds a name/value pair to the multipart request.
     * @param name The name of the value.
     * @param value The value to add.
     * @param contentType The MIME type of the value.
     * @return This HttpRequestMultipart instance, for method chaining.
     * @throws IllegalArgumentException If the name or value is null or empty.
     */
    public HttpRequestMultipart addMultipart(String name, String value, String contentType)
    {
        if (String.isBlank(name) || String.isBlank(value) || String.isBlank(contentType))
        {
            throw new IllegalArgumentException('Name, value and contentType cannot be null or empty');
        }

        String contentDisposition = 'Content-Disposition: form-data; name="' + name + '"; ' + CRLF;
        String contentTypeHeader = 'Content-Type: ' + contentType + '; ' + CRLF;

        this.multipartBodyHex += this.writeBoundary(false);
        this.multipartBodyHex += this.encodeToHexString(contentDisposition);
        this.multipartBodyHex += this.encodeToHexString(contentTypeHeader);
        this.multipartBodyHex += this.encodeToHexString(value + CRLF);

        return this;
    }

    /**
     * Adds a file to the multipart request.
     * @param name The name of the file.
     * @param file The file to add.
     * @param mimeType The MIME type of the file.
     * @param fileName The filename of the file.
     * @return This HttpRequestMultipart instance, for method chaining.
     * @throws IllegalArgumentException If the name, file, mimeType, or fileName is null or empty.
     */
    public HttpRequestMultipart addMultipart(String name, Blob file, String mimeType, String fileName)
    {
        if (String.isBlank(name) || file == null || String.isBlank(mimeType) || String.isBlank(fileName))
        {
            throw new IllegalArgumentException('Name, file, mimeType, and fileName cannot be null or empty');
        }

        String contentDisposition = 'Content-Disposition: form-data; name="' + name + '"; filename="' + fileName + '" ' + CRLF;
        String contentType = 'Content-Type: ' + mimeType + '; ' + CRLF + CRLF;
        String file64 = EncodingUtil.convertToHex(file);

        this.multipartBodyHex += this.writeBoundary(false);
        this.multipartBodyHex += this.encodeToHexString(contentDisposition);
        this.multipartBodyHex += this.encodeToHexString(contentType);
        this.multipartBodyHex += file64;
        this.multipartBodyHex += this.encodeToHexString(CRLF);

        return this;
    }

    /**
     * Constructs an HttpRequest object with the multipart request as the body.
     * @return An HttpRequest object representing the multipart request.
     */
    public HttpRequest request()
    {
        this.multipartBodyHex += this.writeBoundary(true);

        Blob requestBlob = EncodingUtil.convertFromHex(this.multipartBodyHex);

        this.httpRequest.setBodyAsBlob(requestBlob);
        this.httpRequest.setHeader('Connection', 'keep-alive');
        this.httpRequest.setHeader('Content-Length', String.valueOf(requestBlob.size()));

        if (this.httpRequest.getMethod() == null)
        {
            this.httpRequest.setMethod('POST');
        }

        return this.httpRequest;
    }

    /**
     * Converts a string to a hexadecimal representation.
     * @param value The string to convert.
     * @return The hexadecimal representation of the string.
     */
    private String encodeToHexString(String value)
    {
        return EncodingUtil.convertToHex(Blob.valueOf(value));
    }

    /**
     * Writes a boundary string to the multipart request.
     * @param isClosingBoundary Whether the boundary is a closing boundary.
     * @return The hexadecimal representation of the boundary string.
     */
    private String writeBoundary(Boolean isClosingBoundary)
    {
        String boundary = HYPHENS + BOUNDARY + (isClosingBoundary ? HYPHENS : CRLF);
        return this.encodeToHexString(boundary);
    }
}
