page 72320 "EDI Inbound Staging List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "EDI Inbound Staging";
    CardPageId = "EDI Inbound Staging Card";
    Caption = 'EDI Inbound Documents';
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
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    StyleExpr = StatusStyleTxt;
                    ToolTip = 'Specifies the processing status of the document.';
                }
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
                field("File Size (Bytes)"; Rec."File Size (Bytes)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the size of the stored content in bytes.';
                }
                field("Imported By"; Rec."Imported By")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the user who imported the document.';
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
            action(ImportFile)
            {
                ApplicationArea = All;
                Caption = 'Import File';
                ToolTip = 'Upload a Text, XML or JSON file into the inbound staging table.';
                Image = Import;

                trigger OnAction()
                var
                    ImportMgt: Codeunit "EDI Import Mgt.";
                begin
                    if ImportMgt.ImportInboundFile() then
                        CurrPage.Update(false);
                end;
            }
            action(ProcessSelected)
            {
                ApplicationArea = All;
                Caption = 'Process Selected Documents';
                ToolTip = 'Process each selected document one at a time. Documents already processed are skipped.';
                Image = Process;

                trigger OnAction()
                var
                    SelectedStaging: Record "EDI Inbound Staging";
                    WorkStaging: Record "EDI Inbound Staging";
                    Processing: Codeunit "Inbound Document Processing";
                    EntryNos: List of [Integer];
                    EntryNo: Integer;
                    ProcessedCount: Integer;
                    SkippedCount: Integer;
                    FailedCount: Integer;
                    SummaryMsg: Label '%1 processed, %2 skipped, %3 failed.', Comment = '%1 = processed count, %2 = skipped count, %3 = failed count';
                begin
                    CurrPage.SetSelectionFilter(SelectedStaging);
                    if SelectedStaging.FindSet() then
                        repeat
                            EntryNos.Add(SelectedStaging."Entry No.");
                        until SelectedStaging.Next() = 0;

                    foreach EntryNo in EntryNos do
                        if WorkStaging.Get(EntryNo) then
                            case Processing.ProcessDocument(WorkStaging) of
                                "EDI Processing Outcome"::Processed:
                                    ProcessedCount += 1;
                                "EDI Processing Outcome"::Skipped:
                                    SkippedCount += 1;
                                "EDI Processing Outcome"::Failed:
                                    FailedCount += 1;
                            end;

                    CurrPage.Update(false);
                    Message(SummaryMsg, ProcessedCount, SkippedCount, FailedCount);
                end;
            }
            action(ProcessNew)
            {
                ApplicationArea = All;
                Caption = 'Process New Documents';
                ToolTip = 'Process every document with status New. Documents in Error or Processed status are skipped.';
                Image = Start;

                trigger OnAction()
                var
                    NewStaging: Record "EDI Inbound Staging";
                    WorkStaging: Record "EDI Inbound Staging";
                    Processing: Codeunit "Inbound Document Processing";
                    EntryNos: List of [Integer];
                    EntryNo: Integer;
                    ProcessedCount: Integer;
                    FailedCount: Integer;
                    SummaryMsg: Label '%1 processed, %2 failed.', Comment = '%1 = processed count, %2 = failed count';
                begin
                    NewStaging.SetRange(Status, NewStaging.Status::New);
                    if NewStaging.FindSet() then
                        repeat
                            EntryNos.Add(NewStaging."Entry No.");
                        until NewStaging.Next() = 0;

                    foreach EntryNo in EntryNos do
                        if WorkStaging.Get(EntryNo) then
                            case Processing.ProcessDocument(WorkStaging) of
                                "EDI Processing Outcome"::Processed:
                                    ProcessedCount += 1;
                                "EDI Processing Outcome"::Failed:
                                    FailedCount += 1;
                            end;

                    CurrPage.Update(false);
                    Message(SummaryMsg, ProcessedCount, FailedCount);
                end;
            }
            action(DownloadFile)
            {
                ApplicationArea = All;
                Caption = 'Download Original';
                ToolTip = 'Download the originally imported file.';
                Image = Download;
                Scope = Repeater;

                trigger OnAction()
                begin
                    Rec.DownloadOriginal();
                end;
            }
            action(MarkAsProcessed)
            {
                ApplicationArea = All;
                Caption = 'Mark as Processed';
                ToolTip = 'Mark the selected document as processed (PoC stub).';
                Image = Approve;
                Scope = Repeater;

                trigger OnAction()
                begin
                    Rec.MarkProcessed();
                    CurrPage.Update(false);
                end;
            }
            action(CreateOutbound)
            {
                ApplicationArea = All;
                Caption = 'Copy to Outbound';
                ToolTip = 'Create an outbound document from the selected inbound document.';
                Image = CopyDocument;
                Scope = Repeater;

                trigger OnAction()
                var
                    ExportMgt: Codeunit "EDI Export Mgt.";
                    EntryNo: Integer;
                    CreatedMsg: Label 'Outbound entry %1 created.', Comment = '%1 = Entry No.';
                begin
                    EntryNo := ExportMgt.CreateOutboundFromInbound(Rec);
                    Message(CreatedMsg, EntryNo);
                end;
            }
        }
        area(Navigation)
        {
            action(OpenOutbound)
            {
                ApplicationArea = All;
                Caption = 'Outbound Documents';
                ToolTip = 'Open the outbound EDI documents list.';
                Image = ListPage;
                RunObject = page "EDI Outbound Staging List";
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';
                actionref(ProcessSelected_Promoted; ProcessSelected) { }
                actionref(ProcessNew_Promoted; ProcessNew) { }
                actionref(ImportFile_Promoted; ImportFile) { }
                actionref(DownloadFile_Promoted; DownloadFile) { }
                actionref(MarkAsProcessed_Promoted; MarkAsProcessed) { }
                actionref(CreateOutbound_Promoted; CreateOutbound) { }
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
            Rec.Status::Processed:
                StatusStyleTxt := 'Favorable';
            Rec.Status::Error:
                StatusStyleTxt := 'Unfavorable';
            Rec.Status::Processing:
                StatusStyleTxt := 'Ambiguous';
            else
                StatusStyleTxt := 'Standard';
        end;
    end;
}
