package model;

public class TicketAssets {
    private int ticketId;
    private int assetId;

    public TicketAssets() {
    }

    public TicketAssets(int ticketId, int assetId) {
        this.ticketId = ticketId;
        this.assetId = assetId;
    }

    public int getTicketId() {
        return ticketId;
    }

    public void setTicketId(int ticketId) {
        this.ticketId = ticketId;
    }

    public int getAssetId() {
        return assetId;
    }

    public void setAssetId(int assetId) {
        this.assetId = assetId;
    }
}