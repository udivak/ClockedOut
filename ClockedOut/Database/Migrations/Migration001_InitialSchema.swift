import Foundation
import GRDB

enum Migration001_InitialSchema {
    static func migrate(_ db: Database) throws {
        // Create monthly_summaries table
        try db.create(table: "monthly_summaries", ifNotExists: true) { t in
            t.autoIncrementedPrimaryKey("id")
            t.column("month", .text).notNull().unique()
            t.column("weekday_hours", .double).notNull().defaults(to: 0)
            t.column("weekend_hours", .double).notNull().defaults(to: 0)
            t.column("weekday_rate", .double).notNull().defaults(to: 0)
            t.column("weekend_rate", .double).notNull().defaults(to: 0)
            t.column("salary", .double).notNull().defaults(to: 0)
            t.column("created_at", .text).notNull()
            t.column("updated_at", .text).notNull()
        }
        
        // Create weekly_summaries table
        try db.create(table: "weekly_summaries", ifNotExists: true) { t in
            t.autoIncrementedPrimaryKey("id")
            t.column("month_id", .integer).notNull().references("monthly_summaries", onDelete: .cascade)
            t.column("week_start_date", .text).notNull()
            t.column("week_end_date", .text).notNull()
            t.column("weekday_hours", .double).notNull().defaults(to: 0)
            t.column("weekend_hours", .double).notNull().defaults(to: 0)
            t.column("created_at", .text).notNull()
        }
        
        // Create unique constraint on (month_id, week_start_date)
        try db.execute(sql: """
            CREATE UNIQUE INDEX IF NOT EXISTS idx_weekly_summaries_month_week 
            ON weekly_summaries(month_id, week_start_date)
        """)
    }
}

