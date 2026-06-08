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
      date_ranges: [{ start_date: "30daysAgo", end_date: "today" }]
    )
    response&.rows&.first&.metric_values&.first&.value.to_i
  end

  def active_users_last_30_days
    response = run_report(
      metrics: [{ name: "activeUsers" }],
      date_ranges: [{ start_date: "30daysAgo", end_date: "today" }]
    )
    response&.rows&.first&.metric_values&.first&.value.to_i
  end

  def sessions_last_30_days
    response = run_report(
      metrics: [{ name: "sessions" }],
      date_ranges: [{ start_date: "30daysAgo", end_date: "today" }]
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
