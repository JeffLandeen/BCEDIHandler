page 72321 "EDI Inbound Staging Card"
{
    PageType = Card;
    ApplicationArea = All;
    SourceTable = "EDI Inbound Staging";
    Caption = 'EDI Inbound Document';

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
                    ToolTip = 'Specifies the unique entry number of the staged inbound document.';
                }
                field("File Name"; Rec."File Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the original file name of the imported document.';
                }
                field("File Format"; Rec."File Format")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the payload format of the document: Text, XML or JSON.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the processing status of the document.';
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
                    ToolTip = 'Specifies the trading partner the document was received from.';
                }
                field("Inbound Processing Engine"; Rec."Inbound Processing Engine")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the engine used to consume the payload. It is resolved automatically during processing but can be preset.';
                }
            }
            group(Audit)
            {
                Caption = 'Audit';
                field("Received DateTime"; Rec."Received DateTime")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when the document was imported.';
                }
                field("Processed DateTime"; Rec."Processed DateTime")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when the document was marked as processed.';
                }
                field("Imported By"; Rec."Imported By")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the user who imported the document.';
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
            action(ProcessDocument)
            {
                ApplicationArea = All;
                Caption = 'Process Document';
                ToolTip = 'Determine the processing engine and run the matching handler for this document.';
                Image = Process;

                trigger OnAction()
                var
                    Processing: Codeunit "Inbound Document Processing";
                begin
                    Processing.ProcessDocument(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(DownloadFile)
            {
                ApplicationArea = All;
                Caption = 'Download Original';
                ToolTip = 'Download the originally imported file.';
                Image = Download;

                trigger OnAction()
                begin
                    Rec.DownloadOriginal();
                end;
            }
            action(MarkAsProcessed)
            {
                ApplicationArea = All;
                Caption = 'Mark as Processed';
                ToolTip = 'Mark this document as processed (PoC stub).';
                Image = Approve;

                trigger OnAction()
                begin
                    Rec.MarkProcessed();
                    CurrPage.Update(false);
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';
                actionref(ProcessDocument_Promoted; ProcessDocument) { }
                actionref(DownloadFile_Promoted; DownloadFile) { }
                actionref(MarkAsProcessed_Promoted; MarkAsProcessed) { }
            }
        }
    }
}
