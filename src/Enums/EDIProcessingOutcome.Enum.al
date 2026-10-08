enum 72305 "EDI Processing Outcome"
{
    Extensible = false;
    Caption = 'EDI Processing Outcome';

    value(0; Skipped)
    {
        Caption = 'Skipped';
    }
    value(1; Processed)
    {
        Caption = 'Processed';
    }
    value(2; Failed)
    {
        Caption = 'Failed';
    }
}
