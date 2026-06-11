ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: proc { I18n.t("active_admin.dashboard") }

  content title: "Dashboard" do
    @analytics     = AnalyticsService.summary(days: 30)
    @daily_data    = AnalyticsService.daily_data(days: 30)

    # ── Overview metrics panel ─────────────────────────────────────────
    if @analytics
      panel "Overview — Last 30 Days" do
        metrics = [
          {
            label: "Sessions",
            key: :sessions,
            format: :number,
            description: "Browsing sessions by a single user"
          },
          {
            label: "Page Views",
            key: :page_views,
            format: :number,
            description: "Total pages viewed including refreshes"
          },
          {
            label: "Avg. Session Duration",
            key: :avg_session_duration,
            format: :duration,
            description: "Average time spent per session"
          },
          {
            label:"Total Users",
            key: :total_users,
            format: :number,
            description: "Distinct tracked users"
          },
          {
            label: "Bounce Rate",
            key: :bounce_rate,
            format: :percent,
            description: "Sessions without engagement"
          },
          {
            label: "New Users",
            key: :new_users,
            format: :number,
            description: "First time visitors"
          }
        ]

        columns do
          metrics.each do |metric|
            column do
              data     = @analytics[metric[:key]]
              current  = data[:current]
              previous = data[:previous]

              if previous > 0
                change    = ((current - previous).to_f / previous * 100).round(1)
                improved  = metric[:key] == :bounce_rate ? change < 0 : change >= 0
                arrow     = change >= 0 ? "▲" : "▼"
                color     = improved ? "#2d7a2d" : "#c0392b"
              else
                change = 0
                arrow  = "–"
                color  = "#888888"
              end

              display_value = case metric[:format]
                              when :percent  then "#{current}%"
                              when :duration
                                mins = (current / 60).floor
                                secs = (current % 60).round
                                mins > 0 ? "#{mins}m #{secs}s" : "#{secs}s"
                              else
                                number_with_delimiter(current)
                              end

              previous_display = case metric[:format]
                                 when :percent  then "#{previous}%"
                                 when :duration
                                   mins = (previous / 60).floor
                                   secs = (previous % 60).round
                                   mins > 0 ? "#{mins}m #{secs}s" : "#{secs}s"
                                 else
                                   number_with_delimiter(previous)
                                 end

              div style: "padding: 16px; background: #f9f9f9; border-radius: 4px; border-left: 3px solid #5E6469; margin-bottom: 8px;" do
                para metric[:label], style: "font-size: 11px; font-weight: bold; color: #5E6469; margin: 0 0 2px; text-transform: uppercase; letter-spacing: 0.5px;"
                para metric[:description], style: "font-size: 10px; color: #999; margin: 0 0 8px;"
                para display_value, style: "font-size: 28px; font-weight: bold; color: #333; margin: 0 0 6px; line-height: 1;"
                div style: "display: flex; align-items: center; gap: 8px;" do
                  span "#{arrow} #{change.abs}%", style: "font-size: 12px; font-weight: bold; color: #{color};"
                  span "vs #{previous_display} prev 30d", style: "font-size: 11px; color: #999;"
                end
              end
            end
          end
        end

        div style: "text-align: right; margin-top: 12px; padding-top: 8px; border-top: 1px solid #eee;" do
          link_to "View full report in Google Analytics →",
                  "https://analytics.google.com/analytics/web/#/p#{ENV['GA4_PROPERTY_ID']}/reports/intelligenthome",
                  target: "_blank",
                  style: "font-size: 12px; color: #5E6469;"
        end
      end
    end

    # ── Charts panel ───────────────────────────────────────────────────
    if @daily_data.any?
      panel "Last 30 Days — Sessions & Page Views" do
        # Format data for chartkick — needs { label => value } hash
        sessions_data   = @daily_data.map { |d| [d[:date], d[:sessions]] }.to_h
        page_views_data = @daily_data.map { |d| [d[:date], d[:page_views]] }.to_h
        users_data      = @daily_data.map { |d| [d[:date], d[:users]] }.to_h

        # Line chart — sessions and page views over time
        render partial: 'admin/analytics/line_chart',
               locals: {
                 sessions_data: sessions_data,
                 page_views_data: page_views_data,
                 users_data: users_data
               }
      end

      panel "Last 30 Days — Current vs Previous Period" do
        if @analytics
          # Bar chart comparing current vs previous for each metric
          comparison_data = [
            {
              name: "Current 30 Days",
              data: {
                "Sessions" => @analytics[:sessions][:current],
                "Page Views" => @analytics[:page_views][:current],
                "Users" => @analytics[:total_users][:current],
                "New Users" => @analytics[:new_users][:current]
              }
            },
            {
              name: "Previous 30 Days",
              data: {
                "Sessions" => @analytics[:sessions][:previous],
                "Page Views" => @analytics[:page_views][:previous],
                "Users" => @analytics[:total_users][:previous],
                "New Users" => @analytics[:new_users][:previous]
              }
            }
          ]

          render partial: 'admin/analytics/bar_chart',
                 locals: { comparison_data: comparison_data }
        end
      end
    end
  end
end
