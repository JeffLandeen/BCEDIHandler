codeunit 72333 "EDI Payload Parser"
{
    Access = Public;

    /// <summary>
    /// Splits a text payload into a list of lines (CR, LF and CRLF aware).
    /// This is the "memory structure" a flat-file (Text) handler would map from.
    /// </summary>
    procedure ParseAsTextLines(Content: Text) Lines: List of [Text]
    var
        CarriageReturn: Char;
        LineFeed: Char;
        Normalized: Text;
    begin
        CarriageReturn := 13;
        LineFeed := 10;
        Normalized := Content.Replace(Format(CarriageReturn), '');
        Lines := Normalized.Split(Format(LineFeed));
    end;

    /// <summary>
    /// Parses a text payload into an XmlDocument. Raises an error if the
    /// payload is not well-formed XML.
    /// </summary>
    procedure ParseAsXml(Content: Text) Document: XmlDocument
    var
        InvalidXmlErr: Label 'The payload is not valid XML and could not be parsed.';
    begin
        if not XmlDocument.ReadFrom(Content, Document) then
            Error(InvalidXmlErr);
    end;

    /// <summary>
    /// Parses a text payload into a JSON token tree. Raises an error if the
    /// payload is not valid JSON.
    /// </summary>
    procedure ParseAsJson(Content: Text) Root: JsonToken
    var
        InvalidJsonErr: Label 'The payload is not valid JSON and could not be parsed.';
    begin
        if not Root.ReadFrom(Content) then
            Error(InvalidJsonErr);
    end;
}
