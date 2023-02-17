# HttpRequestMultipart Class

The HttpRequestMultipart class is a tool for building multipart/form-data HTTP requests in Salesforce. It is based on the RFC 1341 standard and allows you to add name/value pairs and files to the request. 

**The resulting request can be used with the standard HttpRequest class in Salesforce**.

## Usage

To use the HttpRequestMultipart class, you can instantiate it and then use its methods to add data to the request. Here is an example:

```apex
// Create a new instance of HttpRequestMultipart
HttpRequestMultipart requestMultipart = new HttpRequestMultipart();

// Set the HTTP method
requestMultipart.setHttpMethod('POST');

// Add a name/value pair
requestMultipart.addMultipart('name', 'value', 'text/plain');

// Add a file
Blob fileBlob = Blob.valueOf('file content');
requestMultipart.addMultipart('file', fileBlob, 'image/jpeg', 'image.jpg');

// Get the resulting HttpRequest object
HttpRequest httpRequest = request.requestMultipart();
```

## Methods

The class defines several methods that you can use to add data to the multipart request:

- ***setHttpMethod(String httpMethod):*** Sets the HTTP method for the request.
- ***addMultipart(String name, String value, String contentType):*** Adds a name/value pair to the multipart request.
- ***addMultipart(String name, Blob file, String mimeType, String fileName):*** Adds a file to the multipart request.
- ***request():*** Constructs an HttpRequest object with the multipart request as the body.

## Testing
The HttpRequestMultipart class includes a corresponding test class, HttpRequestMultipartTest. This test class contains test methods to validate the functionality of the HttpRequestMultipart class. It validates the following functionalities:

- Set HTTP method
- Add a JSON-encoded data part to the request body
- Add a file part to the request body
- Build an HttpRequest object from the added parts
- Throw exceptions for invalid input parameters

To run the test class, simply execute it in the Developer Console. The test methods will automatically run and validate the functionality of the HttpRequestMultipart class.

## Credits
This class was created by William Watson on 16/02/2023.
