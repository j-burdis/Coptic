class AnalyticsService
  PROPERTY_ID = ENV.fetch("GA4_PROPERTY_ID")

  def initialize
    @client = Google::Analytics::Data::V1beta::AnalyticsData::Client.new do |config|
      config.credentials = ENV.fetch("GOOGLE_APPLICATION_CREDENTIALS")
    end
  end

  def page_view_last_30_days
    response = run_report(
      metrics: [{ name: "screenPageViews" }],
      date_ranges: [{ start_date: "30daysAgo", end_date: "yesterday" }]
    )
    response&.rows&.first&.metric_values&.first&.value.to_i
  end

  def active_users_last_30_days
    response = run_report(
      metrics: [{ name: "activeUsers" }],
      date_ranges: [{ start_date: "30daysAgo", end_date: "yesterday" }]
    )
    response&.rows&.first&.metric_values&.first&.value.to_i
  end

  def sessions_last_30_days
    response = run_report(
      metrics: [{ name: "sessions" }],
      date_ranges: [{ start_date: "30daysAgo", end_date: "yesterday" }]
    )
    response&.rows&.first&.metric_values&.first&.value.to_i
  end

  def daily_sessions(days: 30)
    response = run_report(
      metrics: [{ name: "sessions" }],
      dimensions: [{ name: "date" }],
      date_ranges: [{ start_date: "30daysAgo", end_date: "today" }],
      order_bys: [{ dimension: { dimension_name: "date" }, desc: false }]
    )

    return [] unless response&.rows

    response.rows.map do |row|
      {
        date: row.dimension_values.first.value,
        sessions: row.metric_values.first.value.to_i
      }
    end
  end

  def self.summary(days: 30)
    Rails.cache.fetch("analytics_summary_#{days}d", expires_in: 1.hour) do
      new.summary(days: days)
    end
  end

  def summary(days: 30)
    response = run_report(
      metrics: [
        { name: "sessions" },
        { name: "screenPageViews" },
        { name: "totalUsers" },
        { name: "newUsers" },
        { name: "bounceRate" },
        { name: "averageSessionDuration" }
      ],
      date_ranges: [
        # date_range_0 = current period
        { start_date: "#{days}daysAgo", end_date: "yesterday" },
        # date_range_1 = previous period  
        { start_date: "#{days * 2}daysAgo", end_date: "#{days + 1}daysAgo" }
      ]
    )

    return nil unless response&.rows

    # GA4 returns rows interleaved when using two date ranges
    # date_range_0 rows come first, date_range_1 rows second
    current  = response.rows.select { |r| r.dimension_values.any? { |d| d.value == "date_range_0" } }
              .flat_map(&:metric_values)
    previous = response.rows.select { |r| r.dimension_values.any? { |d| d.value == "date_range_1" } }
              .flat_map(&:metric_values)

    # If no dimension filter worked, fall back to row index
    if current.empty?
      current  = response.rows[0]&.metric_values || []
      previous = response.rows[1]&.metric_values || []
    end

    {
      sessions: { current: current[0]&.value.to_i, previous: previous[0]&.value.to_i },
      page_views: { current: current[1]&.value.to_i, previous: previous[1]&.value.to_i },
      total_users: { current: current[2]&.value.to_i, previous: previous[2]&.value.to_i },
      new_users: { current: current[3]&.value.to_i, previous: previous[3]&.value.to_i },
      bounce_rate: { current: current[4]&.value.to_f.round(1), previous: previous[4]&.value.to_f.round(1) },
      avg_session_duration: { current: current[5]&.value.to_f.round(0), previous: previous[5]&.value.to_f.round(0) }
    }
  rescue StandardError => e
    Rails.logger.error "[AnalyticsService] #{e.message}"
    nil
  end

  def self.daily_data(days: 30)
    Rails.cache.fetch("analytics_daily_#{days}d", expires_in: 1.hour) do
      new.daily_data(days: days)
    end
  end

  def daily_data(days: 30)
    response = run_report(
      metrics: [
        { name: "sessions" },
        { name: "screenPageViews" },
        { name: "totalUsers" }
      ],
      dimensions: [{ name: "date" }],
      date_ranges: [{ start_date: "#{days}daysAgo", end_date: "today" }],
      order_bys: [{ dimension: { dimension_name: "date" }, desc: false }]
    )

    return [] unless response&.rows

    response.rows.map do |row|
      date = row.dimension_values.first.value
      # GA4 returns dates as YYYYMMDD — convert to readable format for charts
      formatted_date = Date.strptime(date, "%Y%m%d").strftime("%d %b")
      {
        date: formatted_date,
        sessions: row.metric_values[0].value.to_i,
        page_views: row.metric_values[1].value.to_i,
        users: row.metric_values[2].value.to_i
      }
    end
  rescue StandardError => e
    Rails.logger.error "[AnalyticsService] Daily data error: #{e.message}"
    []
  end

  private

  def run_report(metrics:, date_ranges:, dimensions: [], order_bys: [])
    request = {
      property: "properties/#{PROPERTY_ID}",
      metrics: metrics,
      date_ranges: date_ranges,
      dimensions: dimensions,
      order_bys: order_bys
    }
    @client.run_report(request)
  rescue Google::Cloud::PermissionDeniedError => e
    Rails.logger.error "[AnalyticsService] Permission Denied - check service account has access to GA property: #{e.message}"
    nil
  rescue Google::Cloud::NotFoundError => e
    Rails.logger.error "[AnalyticsService] Property not found - check GA4_PROPERTY_ID is correct: #{e.message}"
    nil
  rescue StandardError => e
    Rails.logger.error "[AnalyticsService] Unexpected error: #{e.class} - #{e.message}"
    nil
  end
end
