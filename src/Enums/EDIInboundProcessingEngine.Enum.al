enum 72304 "EDI Inbound Processing Engine" implements "EDI Inbound Doc. Processor"
{
    Extensible = true;
    Caption = 'EDI Inbound Processing Engine';

    value(0; "Base 850 - Order")
    {
        Caption = 'Base 850 - Order';
        Implementation = "EDI Inbound Doc. Processor" = "EDI Proc. 850 Order";
    }
    value(1; "Base 855 - Ack")
    {
        Caption = 'Base 855 - Ack';
        Implementation = "EDI Inbound Doc. Processor" = "EDI Proc. 855 Ack";
    }
    value(2; "Base 856 - ASN")
    {
        Caption = 'Base 856 - ASN';
        Implementation = "EDI Inbound Doc. Processor" = "EDI Proc. 856 ASN";
    }
    value(3; "Base 810 - Invoice")
    {
        Caption = 'Base 810 - Invoice';
        Implementation = "EDI Inbound Doc. Processor" = "EDI Proc. 810 Invoice";
    }
}
