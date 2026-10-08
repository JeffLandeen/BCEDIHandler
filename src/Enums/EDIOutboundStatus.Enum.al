enum 72302 "EDI Outbound Status"
{
    Extensible = true;
    Caption = 'EDI Outbound Status';

    value(0; New)
    {
        Caption = 'New';
    }
    value(1; ReadyToExport)
    {
        Caption = 'Ready to Export';
    }
    value(2; Exported)
    {
        Caption = 'Exported';
    }
    value(3; Error)
    {
        Caption = 'Error';
    }
}
