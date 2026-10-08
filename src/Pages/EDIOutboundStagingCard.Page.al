page 72323 "EDI Outbound Staging Card"
{
    PageType = Card;
    ApplicationArea = All;
    SourceTable = "EDI Outbound Staging";
    Caption = 'EDI Outbound Document';

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unique entry number of the staged outbound document.';
                }
                field("File Name"; Rec."File Name")
                {
                    ApplicationArea = All;
                    Editable = true;
                    ToolTip = 'Specifies the file name that will be used on export.';
                }
                field("File Format"; Rec."File Format")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the payload format of the document: Text, XML or JSON.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the export status of the document.';
                }
                field("Error Message"; Rec."Error Message")
                {
                    ApplicationArea = All;
                    MultiLine = true;
                    ToolTip = 'Specifies the last error recorded for the document.';
                }
            }
            group(Routing)
            {
                Caption = 'Routing';
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether the document is an EDI Document or a Master Data Update.';
                }
                field("EDI Document ID"; Rec."EDI Document ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the EDI transaction set identifier (for example 850, 855, 856 or 810).';
                }
                field("Trading Partner ID"; Rec."Trading Partner ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the trading partner the document is addressed to.';
                }
            }
            group(Audit)
            {
                Caption = 'Audit';
                field("Created DateTime"; Rec."Created DateTime")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when the document was created.';
                }
                field("Exported DateTime"; Rec."Exported DateTime")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when the document was exported.';
                }
                field("Source Inbound Entry No."; Rec."Source Inbound Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the inbound entry this document was copied from, if any.';
                }
                field("File Size (Bytes)"; Rec."File Size (Bytes)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the size of the stored content in bytes.';
                }
            }
            group(Preview)
            {
                Caption = 'Content Preview';
                field("Content Preview"; Rec."Content Preview")
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                    MultiLine = true;
                    ToolTip = 'Shows the first part of the stored content.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ExportFile)
            {
                ApplicationArea = All;
                Caption = 'Export File';
                ToolTip = 'Download this outbound document as a file.';
                Image = Export;

                trigger OnAction()
                begin
                    Rec.ExportToFile();
                    CurrPage.Update(false);
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';
                actionref(ExportFile_Promoted; ExportFile) { }
            }
        }
    }
}
