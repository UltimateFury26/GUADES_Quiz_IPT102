<%@ Page Title="Reports" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Reports.aspx.cs" Inherits="_24_1571GuadesPersonalPortfolio.ReportsPage" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

    <div class="admin-head">
        <div>
            <h1 class="admin-title">Reports</h1>
            <p class="admin-sub">Live statistics about registered accounts and the website's content.</p>
        </div>
    </div>

    <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="alert alert-error" role="alert">
        <asp:Literal ID="litMessage" runat="server" Mode="Encode" />
    </asp:Panel>

    <asp:Panel ID="pnlReport" runat="server">

        <!-- SUMMARY CARDS -->
        <div class="stat-grid">
            <div class="stat-card">
                <p class="stat-value"><asp:Literal ID="litTotal" runat="server" Mode="Encode" /></p>
                <p class="stat-label">Total users</p>
            </div>
            <div class="stat-card">
                <p class="stat-value"><asp:Literal ID="litActive" runat="server" Mode="Encode" /></p>
                <p class="stat-label">Active</p>
            </div>
            <div class="stat-card">
                <p class="stat-value"><asp:Literal ID="litInactive" runat="server" Mode="Encode" /></p>
                <p class="stat-label">Inactive</p>
            </div>
            <div class="stat-card">
                <p class="stat-value"><asp:Literal ID="litAdmins" runat="server" Mode="Encode" /></p>
                <p class="stat-label">Admins</p>
            </div>
            <div class="stat-card">
                <p class="stat-value"><asp:Literal ID="litNew" runat="server" Mode="Encode" /></p>
                <p class="stat-label">New this month</p>
            </div>
        </div>

        <div class="report-grid">

            <!-- SIGNUPS PER MONTH (pure CSS bars) -->
            <section class="report-card" aria-labelledby="signupsHeading">
                <h2 id="signupsHeading" class="report-title">Signups per month</h2>
                <p class="report-sub"><asp:Literal ID="litSignupTotal" runat="server" Mode="Encode" /></p>

                <asp:Repeater ID="rptSignups" runat="server">
                    <HeaderTemplate>
                        <div class="bar-chart">
                    </HeaderTemplate>
                    <ItemTemplate>
                            <div class="bar-col" title="<%#: Eval("Tooltip") %>">
                                <span class="bar-value"><%# Eval("Signups") %></span>
                                <div class="bar-track">
                                    <div class="bar-fill" style="height: <%# Eval("HeightPercent") %>%"></div>
                                </div>
                                <span class="bar-label"><%#: Eval("Month") %><br /><%#: Eval("Year") %></span>
                            </div>
                    </ItemTemplate>
                    <FooterTemplate>
                        </div>
                    </FooterTemplate>
                </asp:Repeater>
            </section>

            <!-- ACTIVE VS INACTIVE -->
            <section class="report-card" aria-labelledby="statusHeading">
                <h2 id="statusHeading" class="report-title">Active vs. inactive</h2>
                <p class="report-sub">Share of all registered accounts.</p>

                <div class="split-bar" role="img" aria-label="Active versus inactive accounts">
                    <asp:Panel ID="pnlBarActive" runat="server" CssClass="split-active" />
                    <asp:Panel ID="pnlBarInactive" runat="server" CssClass="split-inactive" />
                </div>

                <ul class="split-legend">
                    <li><span class="legend-dot legend-active"></span>Active <strong><asp:Literal ID="litActiveLegend" runat="server" Mode="Encode" /></strong></li>
                    <li><span class="legend-dot legend-inactive"></span>Inactive <strong><asp:Literal ID="litInactiveLegend" runat="server" Mode="Encode" /></strong></li>
                </ul>
            </section>

        </div>

        <!-- USER VISITS (Users only; the Admin's own visits are never counted) -->
        <h2 class="report-heading">Portfolio visits</h2>
        <p class="report-sub"><asp:Literal ID="litVisitNote" runat="server" Mode="Encode" /></p>

        <div class="stat-grid">
            <div class="stat-card">
                <p class="stat-value"><asp:Literal ID="litVisitTotal" runat="server" Mode="Encode" /></p>
                <p class="stat-label">Total visits</p>
            </div>
            <div class="stat-card">
                <p class="stat-value"><asp:Literal ID="litVisitUnique" runat="server" Mode="Encode" /></p>
                <p class="stat-label">Unique visitors</p>
            </div>
            <div class="stat-card">
                <p class="stat-value"><asp:Literal ID="litVisitToday" runat="server" Mode="Encode" /></p>
                <p class="stat-label">Today</p>
            </div>
            <div class="stat-card">
                <p class="stat-value"><asp:Literal ID="litVisitMonth" runat="server" Mode="Encode" /></p>
                <p class="stat-label">This month</p>
            </div>
        </div>

        <section class="report-card" aria-labelledby="visitsHeading">
            <h2 id="visitsHeading" class="report-title">Visits per month</h2>
            <p class="report-sub"><asp:Literal ID="litVisitsTotalNote" runat="server" Mode="Encode" /></p>

            <asp:Repeater ID="rptVisits" runat="server">
                <HeaderTemplate>
                    <div class="bar-chart">
                </HeaderTemplate>
                <ItemTemplate>
                        <div class="bar-col" title="<%#: Eval("Tooltip") %>">
                            <span class="bar-value"><%# Eval("Visits") %></span>
                            <div class="bar-track">
                                <div class="bar-fill" style="height: <%# Eval("HeightPercent") %>%"></div>
                            </div>
                            <span class="bar-label"><%#: Eval("Month") %><br /><%#: Eval("Year") %></span>
                        </div>
                </ItemTemplate>
                <FooterTemplate>
                    </div>
                </FooterTemplate>
            </asp:Repeater>
        </section>

        <!-- LATEST SIGNUPS -->
        <h2 class="report-heading">Latest signups</h2>
        <div class="table-scroll">
            <asp:Repeater ID="rptRecent" runat="server">
                <HeaderTemplate>
                    <table class="data-table">
                        <thead>
                            <tr>
                                <th scope="col">Username</th>
                                <th scope="col">Email</th>
                                <th scope="col">Role</th>
                                <th scope="col">Status</th>
                                <th scope="col">Joined</th>
                            </tr>
                        </thead>
                        <tbody>
                </HeaderTemplate>
                <ItemTemplate>
                            <tr>
                                <td class="cell-strong"><%#: Eval("Username") %></td>
                                <td class="cell-wrap"><%#: Eval("Email") %></td>
                                <td><span class="<%# RoleBadgeClass(Eval("Role")) %>"><%#: Eval("Role") %></span></td>
                                <td><span class="<%# StatusBadgeClass(Eval("Status")) %>"><%#: Eval("Status") %></span></td>
                                <td><%# FormatDate(Eval("CreatedAt")) %></td>
                            </tr>
                </ItemTemplate>
                <FooterTemplate>
                        </tbody>
                    </table>
                </FooterTemplate>
            </asp:Repeater>
        </div>

        <!-- CONTENT SUMMARY -->
        <h2 class="report-heading">Website content</h2>
        <div class="table-scroll">
            <asp:Repeater ID="rptContent" runat="server">
                <HeaderTemplate>
                    <table class="data-table data-table-compact">
                        <thead>
                            <tr>
                                <th scope="col">Section</th>
                                <th scope="col">Items</th>
                            </tr>
                        </thead>
                        <tbody>
                </HeaderTemplate>
                <ItemTemplate>
                            <tr>
                                <td class="cell-strong"><%#: Eval("Section") %></td>
                                <td><%# Eval("Items") %></td>
                            </tr>
                </ItemTemplate>
                <FooterTemplate>
                        </tbody>
                    </table>
                </FooterTemplate>
            </asp:Repeater>
        </div>

    </asp:Panel>

</asp:Content>
