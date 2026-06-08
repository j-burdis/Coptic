# frozen_string_literal: true

ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: proc { I18n.t("active_admin.dashboard") }

  content title: proc { I18n.t("active_admin_dashboard") } do
    analytics = AnalyticsService.new

    columns do
      column do
        panel "Analytics (Last 30 Days)" do
          attributes_table_for OpenStruct.new(
            page_views: analytics.page_view_last_30_days,
            active_users: analytics.active_users_last_30_days,
            sessions: analytics.sessions_last_30_days
          ) do
            row("Page Views") { |a| a.page_views }
            row("Active Users") { |a| a.active_users }
            row("Sessions") { |a| a.sessions }
          end
        end
      end
    end

    columns do
      column do
        panel "Daily Sessions (Last 30 Days)" do
          daily = analytics.daily_sessions(days: 30)
          if daily.any?
            table_for daily do
              column("Date") { |row| row[:date] }
              column("Sessions") { |row| row[:sessions] }
            end
          else
            para "No date available"
          end
        end
      end
    end
  end
end
