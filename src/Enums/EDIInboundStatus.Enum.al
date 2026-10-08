enum 72301 "EDI Inbound Status"
{
    Extensible = true;
    Caption = 'EDI Inbound Status';

    value(0; New)
    {
        Caption = 'New';
    }
    value(1; Processing)
    {
        Caption = 'Processing';
    }
    value(2; Processed)
    {
        Caption = 'Processed';
    }
    value(3; Error)
    {
        Caption = 'Error';
    }
}
