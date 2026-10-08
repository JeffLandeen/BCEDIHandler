/// <summary>
/// Contract implemented by every inbound EDI processing engine and by each
/// engine/file-format permutation handler. The dispatcher resolves the engine
/// from the staging record, obtains this interface from the
/// "EDI Inbound Processing Engine" enum, and calls ProcessInbound.
/// </summary>
interface "EDI Inbound Doc. Processor"
{
    /// <summary>
    /// Consumes the payload on the supplied inbound staging record and applies
    /// it to Business Central. Implementations should raise an error to signal
    /// failure; the caller treats a clean return as success.
    /// </summary>
    procedure ProcessInbound(var EDIInboundStaging: Record "EDI Inbound Staging");
}
