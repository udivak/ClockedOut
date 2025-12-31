import Foundation
import GRDB

enum Migration002_AddIndexes {
    static func migrate(_ db: Database) throws {
        // Index on month column for faster lookups
        try db.execute(sql: """
            CREATE INDEX IF NOT EXISTS idx_monthly_summaries_month 
            ON monthly_summaries(month)
        """)
        
        // Index on month_id for faster weekly summary lookups
        try db.execute(sql: """
            CREATE INDEX IF NOT EXISTS idx_weekly_summaries_month_id 
            ON weekly_summaries(month_id)
        """)
        
        // Index on week dates for range queries
        try db.execute(sql: """
            CREATE INDEX IF NOT EXISTS idx_weekly_summaries_week_dates 
            ON weekly_summaries(week_start_date, week_end_date)
        """)
    }
}

