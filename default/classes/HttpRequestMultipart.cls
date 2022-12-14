/**
 * Created by William Watson on 13/12/2022.
 *
 * Based on: https://www.w3.org/Protocols/rfc1341/7_2_Multipart.html
 */

public with sharing class HttpRequestMultipart {

    private final static String BOUNDARY = 'gc0p4Jq0M2Yt08jU534c0p';
    private final static String HYPHENS = '--';
    private final static String CR = '\r';
    private final static String LF = '\n';
    private final static String CRLF = CR + LF;

    private HttpRequest httpRequest;
    private String multipartBodyHex = '';

    public HttpRequestMultipart()
    {
        this.httpRequest = new HttpRequest();
        this.httpRequest.setHeader('Content-Type', 'multipart/mixed; boundary=' + BOUNDARY);
    }

    public HttpRequestMultipart addMultipart(String messageName, String json)
    {
        String contentDisposition = 'Content-Disposition: form-data; name="' + messageName + '"; ' + CRLF;
        String contentType = 'Content-Type: application/json; ' + CRLF + CRLF;

        this.multipartBodyHex += this.writeBoundary();
        this.multipartBodyHex += this.encodeToHexString(contentDisposition);
        this.multipartBodyHex += this.encodeToHexString(contentType);
        this.multipartBodyHex += this.encodeToHexString(json + CRLF);

        return this;
    }

    public HttpRequestMultipart addMultipart(String messageName, Blob file, String mimeType)
    {
        String contentDisposition = 'Content-Disposition: form-data; name="' + messageName + '"; ' + CRLF;
        String contentType = 'Content-Type: ' + mimeType + '; ' + CRLF + CRLF;
        String file64 = EncodingUtil.convertToHex(file);

        this.multipartBodyHex += this.writeBoundary();
        this.multipartBodyHex += this.encodeToHexString(contentDisposition);
        this.multipartBodyHex += this.encodeToHexString(contentType);
        this.multipartBodyHex += file64;

        return this;
    }

    public HttpRequest request()
    {
        this.multipartBodyHex += this.writeBoundary(true);

        Blob requestBlob = EncodingUtil.convertFromHex(this.multipartBodyHex);

        this.httpRequest.setBodyAsBlob(requestBlob);
        this.httpRequest.setHeader('Connection', 'keep-alive');
        this.httpRequest.setHeader('Content-Length', String.valueOf(requestBlob.size()));
        this.httpRequest.setMethod('POST');

        return this.httpRequest;
    }

    private String encodeToHexString(String value)
    {
        return EncodingUtil.convertToHex(Blob.valueOf(value));
    }

    private String writeBoundary()
    {
        return this.writeBoundary(false);
    }

    private String writeBoundary(Boolean isClosingBoundary)
    {
        String boundary = HYPHENS + BOUNDARY;
        boundary += isClosingBoundary == true ? HYPHENS : CRLF;
        return this.encodeToHexString(boundary);
    }

}