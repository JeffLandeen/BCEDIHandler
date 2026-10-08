codeunit 72332 "Inbound Document Processing"
{
    Access = Public;

    /// <summary>
    /// Processes a single inbound EDI document:
    ///   * Records already in status Processed are skipped (process-once rule).
    ///   * The processing engine is resolved from the document metadata.
    ///   * The engine/format handler is invoked fault-tolerantly: any error is
    ///     captured, the record is flagged Error and the message stored.
    ///   * A clean return is treated as success and the record is marked Processed.
    /// Returns the outcome so batch callers can summarise their results.
    /// </summary>
    procedure ProcessDocument(var EDIInboundStaging: Record "EDI Inbound Staging") Outcome: Enum "EDI Processing Outcome"
    var
        SelectedEngine: Enum "EDI Inbound Processing Engine";
        ErrorText: Text;
        Succeeded: Boolean;
    begin
        // Process-once guard: never reprocess a completed document.
        if EDIInboundStaging.Status = EDIInboundStaging.Status::Processed then
            exit(Outcome::Skipped);

        SelectedEngine := DetermineEngine(EDIInboundStaging);

        // Fault-tolerant call. Any database writes the handler performs are
        // rolled back automatically if it errors; we then record the failure.
        Succeeded := TryRunEngine(SelectedEngine, EDIInboundStaging);
        if not Succeeded then
            ErrorText := GetLastErrorText();

        // Re-read a clean baseline (the failed handler's changes are rolled back)
        // and stamp the final result.
        EDIInboundStaging.Get(EDIInboundStaging."Entry No.");
        EDIInboundStaging."Inbound Processing Engine" := SelectedEngine;
        if Succeeded then begin
            EDIInboundStaging.Status := EDIInboundStaging.Status::Processed;
            EDIInboundStaging."Processed DateTime" := CurrentDateTime();
            EDIInboundStaging."Error Message" := '';
            Outcome := Outcome::Processed;
        end else begin
            EDIInboundStaging.Status := EDIInboundStaging.Status::Error;
            EDIInboundStaging."Error Message" := CopyStr(ErrorText, 1, MaxStrLen(EDIInboundStaging."Error Message"));
            Outcome := Outcome::Failed;
        end;
        EDIInboundStaging.Modify(true);
    end;

    [TryFunction]
    local procedure TryRunEngine(SelectedEngine: Enum "EDI Inbound Processing Engine"; var EDIInboundStaging: Record "EDI Inbound Staging")
    var
        Processor: Interface "EDI Inbound Doc. Processor";
    begin
        // The enum implements the interface, so this yields the engine's router,
        // which in turn dispatches to the correct file-format handler.
        Processor := SelectedEngine;
        Processor.ProcessInbound(EDIInboundStaging);
    end;

    /// <summary>
    /// Resolves the processing engine from the document's routing metadata.
    /// A production implementation would weigh Trading Partner ID, Document
    /// Category and the payload as well; this PoC keys off the EDI Document ID
    /// and falls back to whatever engine is already set on the record.
    /// </summary>
    local procedure DetermineEngine(var EDIInboundStaging: Record "EDI Inbound Staging"): Enum "EDI Inbound Processing Engine"
    begin
        case EDIInboundStaging."EDI Document ID" of
            '850':
                exit("EDI Inbound Processing Engine"::"Base 850 - Order");
            '855':
                exit("EDI Inbound Processing Engine"::"Base 855 - Ack");
            '856':
                exit("EDI Inbound Processing Engine"::"Base 856 - ASN");
            '810':
                exit("EDI Inbound Processing Engine"::"Base 810 - Invoice");
            else
                exit(EDIInboundStaging."Inbound Processing Engine");
        end;
    end;
}
