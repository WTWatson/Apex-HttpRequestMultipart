/**
 * This Apex Unit Test class contains test methods to validate the functionality of the HttpRequestMultipart class.
 * HttpRequestMultipart is a custom class that allows for building and sending multipart/form-data HTTP requests.
 * It allows for adding multiple parts (i.e., data and files) to a single request body.
 *
 * This class validates the following functionalities:
 * - Set HTTP method
 * - Add a JSON-encoded data part to the request body
 * - Add a file part to the request body
 * - Build an HttpRequest object from the added parts
 * - Throw exceptions for invalid input parameters
 *
 * Created by William Watson on 16/02/2023.
 */
@IsTest
public with sharing class HttpRequestMultipartTest {

    /**
     * The following constants are used as mock data in the test methods.
     */
    private static final String MESSAGE_DATA = 'data';
    private static final String MESSAGE_FILES = 'files';
    private static final String MOCK_JSON = '{ "Hello": "World" }';
    private static final String MOCK_JSON_MIME_TYPE = 'application/json';
    private static final String MOCK_FILENAME = 'test.png';
    private static final String MOCK_FILE_MIME_TYPE = 'image/png';
    private static final String MOCK_FILE_DATA = 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==';
    private static final Blob MOCK_FILE = Blob.valueOf(MOCK_FILE_DATA);

    /**
      * The following constants are used as error messages in the exception tests.
      */
    private static final String EXCEPTION_STANDARD = 'Name, value and contentType cannot be null or empty';
    private static final String EXCEPTION_FILE = 'Name, file, mimeType, and fileName cannot be null or empty';

    /**
     * The MultipartParameters class is a private class used to store the parameters of the multipart request parts.
     * The class has two constructors, one for adding a data part and one for adding a file part.
     */
    private class MultipartParameters {
        public String key;
        public Object value;
        public String contentType;
        public String mimeType;
        public String fileName;

        public MultipartParameters(String key, String value, String contentType)
        {
            this.key = key;
            this.value = (String) value;
            this.contentType = contentType;
        }

        public MultipartParameters(String key, Blob file, String mimeType, String fileName)
        {
            this.key = key;
            this.value = (Blob) file;
            this.mimeType = mimeType;
            this.fileName = fileName;
        }
    }

    /**
     * The following test method tests that the HTTP method can be set correctly.
     * It creates an instance of the HttpRequestMultipart class, sets the HTTP method to 'GET',
     * and then checks that the HttpRequest object has the expected method.
     */
    @IsTest
    public static void givenValidHttpMethod_whenSetHttpMethod_thenShouldSetHttpRequestMethod()
    {
        Test.startTest();
        HttpRequestMultipart httpRequestMultipart = new HttpRequestMultipart();
        httpRequestMultipart.setHttpMethod('GET');
        Test.stopTest();

        System.assertEquals('GET', httpRequestMultipart.httpRequest.getMethod(),
                'Expected HttpRequest method to be set to GET');
    }

    /**
     * The following test method tests that a JSON-encoded data part can be added to the request body.
     * It creates an instance of the HttpRequestMultipart class, adds a data part with the mock JSON data,
     * and then checks that the HttpRequest object has the expected data part in its body.
     */
    @IsTest
    public static void givenValidJsonAndContentType_whenAddMultipart_thenShouldEncodeDataIntoBody()
    {
        Test.startTest();
        HttpRequestMultipart httpRequestMultipart = new HttpRequestMultipart();
        httpRequestMultipart.addMultipart(MESSAGE_DATA, MOCK_JSON, MOCK_JSON_MIME_TYPE);
        Test.stopTest();

        String decodedRequest = decodeHexString(httpRequestMultipart.multipartBodyHex);

        Assert.areEqual(true,decodedRequest.contains('Content-Disposition: form-data; name="' + MESSAGE_DATA + '"'),
                'Expected Content-Disposition by body key to be in request body.');

        Assert.areEqual(true,decodedRequest.contains('Content-Type: application/json;'),
                'Expected JSON Content Type to be in request body.');

        Assert.areEqual(true,decodedRequest.contains(MOCK_JSON),
                'Expected JSON data to be in request body.');
    }

    /**
    * The following test method tests that a file part can be added to the request body.
    * It creates an instance of the HttpRequestMultipart class, adds a file part with the mock file data,
    * and then checks that the HttpRequest object has the expected file part in its body.
    */
    @IsTest
    public static void givenValidBlobAndContentType_whenAddMultipart_thenShouldEncodeDataIntoBody()
    {
        Test.startTest();
        HttpRequestMultipart httpRequestMultipart = new HttpRequestMultipart();
        httpRequestMultipart.addMultipart(MESSAGE_FILES, MOCK_FILE, MOCK_FILE_MIME_TYPE, MOCK_FILENAME);
        Test.stopTest();

        String decodedRequest = decodeHexString(httpRequestMultipart.multipartBodyHex);

        Assert.areEqual(true,decodedRequest.contains('Content-Disposition: form-data; name="' + MESSAGE_FILES + '"; filename="' + MOCK_FILENAME + '"'),
                'Expected Content-Disposition by body key, and filename to be in request body.');

        Assert.areEqual(true,decodedRequest.contains('Content-Type: ' + MOCK_FILE_MIME_TYPE + ';'),
                'Expected ' + MOCK_FILE_MIME_TYPE + ' Content Type to be in request body.');

        Assert.areEqual(true,decodedRequest.contains(MOCK_FILE_DATA),
                'Expected encoded file data to be in request body.');
    }

    /**
     * The following test method tests that an HttpRequest object can be built from the added parts.
     * It creates an instance of the HttpRequestMultipart class, adds both a data part and a file part,
     * and then builds an HttpRequest object from the added parts. It checks that the HttpRequest object
     * has the expected Content-Type header and the expected data and file parts in its body.
     */
    @IsTest
    public static void givenValidJsonAndBlob_whenRequest_thenShouldReturnHttpRequestWithHeaderAndEncodedBody()
    {
        Test.startTest();
        HttpRequestMultipart httpRequestMultipart = new HttpRequestMultipart();
        httpRequestMultipart.addMultipart(MESSAGE_DATA, MOCK_JSON, MOCK_JSON_MIME_TYPE);
        httpRequestMultipart.addMultipart(MESSAGE_FILES, MOCK_FILE, MOCK_FILE_MIME_TYPE, MOCK_FILENAME);
        HttpRequest httpRequest = httpRequestMultipart.request();
        Test.stopTest();

        String bodyAsString = httpRequest.getBody();
        String contentTypeHeader = httpRequest.getHeader('Content-Type');

        Assert.areEqual(true,contentTypeHeader.contains('multipart/mixed;'),
                'Expected Content-Type to be multipart/mixed;');

        Assert.areEqual(true,bodyAsString.contains(MOCK_JSON),
                'Expected JSON data to be in request body.');

        Assert.areEqual(true,bodyAsString.contains(MOCK_FILE_DATA),
                'Expected encoded file data to be in request body.');
    }

    /**
     * The following test methods test that the HttpRequestMultipart class throws exceptions for invalid input parameters.
     * The tests cover different combinations of null/empty values for the key, value, file, mimeType, and fileName parameters.
     */
    @IsTest
    public static void givenEmptyKey_whenAddMultipart_thenShouldThrowException()
    {
        Test.startTest();
        assertThrowsExceptionWithMessage(
                EXCEPTION_STANDARD,
                new HttpRequestMultipart(),
                new MultipartParameters('', MOCK_JSON, MOCK_JSON_MIME_TYPE)
        );
        assertThrowsExceptionWithMessage(
                EXCEPTION_FILE,
                new HttpRequestMultipart(),
                new MultipartParameters('', MOCK_FILE, MOCK_FILE_MIME_TYPE, MOCK_FILENAME)
        );
        Test.stopTest();
    }

    @IsTest
    public static void givenNullKey_whenAddMultipart_thenShouldThrowException()
    {
        Test.startTest();
        assertThrowsExceptionWithMessage(
                EXCEPTION_STANDARD,
                new HttpRequestMultipart(),
                new MultipartParameters(null, MOCK_JSON, MOCK_JSON_MIME_TYPE)
        );
        assertThrowsExceptionWithMessage(
                EXCEPTION_FILE,
                new HttpRequestMultipart(),
                new MultipartParameters(null, MOCK_FILE, MOCK_FILE_MIME_TYPE, MOCK_FILENAME)
        );
        Test.stopTest();
    }

    @IsTest
    public static void givenNullValue_whenAddMultipart_thenShouldThrowException()
    {
        Test.startTest();
        assertThrowsExceptionWithMessage(
                EXCEPTION_FILE,
                new HttpRequestMultipart(),
                new MultipartParameters(MESSAGE_DATA, null, MOCK_JSON_MIME_TYPE)
        );
        Test.stopTest();
    }

    @IsTest
    public static void givenNullFile_whenAddMultipart_thenShouldThrowException()
    {
        Test.startTest();
        assertThrowsExceptionWithMessage(
                EXCEPTION_FILE,
                new HttpRequestMultipart(),
                new MultipartParameters(MESSAGE_FILES, null, MOCK_FILE_MIME_TYPE, MOCK_FILENAME)
        );
        Test.stopTest();
    }

    private static String decodeHexString(String hex)
    {
        return EncodingUtil.convertFromHex(hex).toString();
    }

    /**
     * The following private method is used in the exception tests to assert that an exception is thrown with the expected message.
     */
    private static void assertThrowsExceptionWithMessage(String expectedMessage, HttpRequestMultipart multipart, MultipartParameters parameters)
    {
        try
        {
            if (parameters.value != null)
            {
                if (parameters.value instanceof Blob)
                {
                    multipart.addMultipart(parameters.key, (Blob) parameters.value, parameters.contentType, parameters.fileName);
                }
                else
                {
                    multipart.addMultipart(parameters.key, (String) parameters.value, parameters.contentType);
                }
            }
            else
            {
                multipart.addMultipart(parameters.key, null, parameters.contentType, parameters.fileName);
            }
            Assert.isTrue(false, 'Expected exception to be thrown');
        }
        catch (Exception e)
        {
            Assert.areEqual(expectedMessage, e.getMessage());
        }
    }
}