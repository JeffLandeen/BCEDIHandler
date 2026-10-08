page 72322 "EDI Outbound Staging List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "EDI Outbound Staging";
    CardPageId = "EDI Outbound Staging Card";
    Caption = 'EDI Outbound Documents';
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unique entry number of the staged outbound document.';
                }
                field("File Name"; Rec."File Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the file name that will be used on export.';
                }
                field("File Format"; Rec."File Format")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the payload format of the document: Text, XML or JSON.';
                }
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
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    StyleExpr = StatusStyleTxt;
                    ToolTip = 'Specifies the export status of the document.';
                }
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
                field("File Size (Bytes)"; Rec."File Size (Bytes)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the size of the stored content in bytes.';
                }
                field("Source Inbound Entry No."; Rec."Source Inbound Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the inbound entry this document was copied from, if any.';
                }
                field("Error Message"; Rec."Error Message")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the last error recorded for the document.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(CreateSample)
            {
                ApplicationArea = All;
                Caption = 'Create Sample';
                ToolTip = 'Create a sample outbound document (Text, XML or JSON) to demonstrate export.';
                Image = NewDocument;

                trigger OnAction()
                var
                    ExportMgt: Codeunit "EDI Export Mgt.";
                    FileFormat: Enum "EDI File Format";
                    Selection: Integer;
                begin
                    Selection := StrMenu('Text,XML,JSON', 1, 'Select sample file format');
                    case Selection of
                        0:
                            exit;
                        1:
                            FileFormat := FileFormat::Text;
                        2:
                            FileFormat := FileFormat::XML;
                        3:
                            FileFormat := FileFormat::JSON;
                    end;
                    ExportMgt.CreateSampleOutbound(FileFormat);
                    CurrPage.Update(false);
                end;
            }
            action(ExportFile)
            {
                ApplicationArea = All;
                Caption = 'Export File';
                ToolTip = 'Download the selected outbound document as a file.';
                Image = Export;
                Scope = Repeater;

                trigger OnAction()
                begin
                    Rec.ExportToFile();
                    CurrPage.Update(false);
                end;
            }
        }
        area(Navigation)
        {
            action(OpenInbound)
            {
                ApplicationArea = All;
                Caption = 'Inbound Documents';
                ToolTip = 'Open the inbound EDI documents list.';
                Image = ListPage;
                RunObject = page "EDI Inbound Staging List";
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';
                actionref(CreateSample_Promoted; CreateSample) { }
                actionref(ExportFile_Promoted; ExportFile) { }
            }
        }
    }

    var
        StatusStyleTxt: Text;

    trigger OnAfterGetRecord()
    begin
        SetStatusStyle();
    end;

    local procedure SetStatusStyle()
    begin
        case Rec.Status of
            Rec.Status::Exported:
                StatusStyleTxt := 'Favorable';
            Rec.Status::Error:
                StatusStyleTxt := 'Unfavorable';
            Rec.Status::ReadyToExport:
                StatusStyleTxt := 'Ambiguous';
            else
                StatusStyleTxt := 'Standard';
        end;
    end;
}
