import XCTest
#if GRDBCUSTOMSQLITE
    import GRDBCustomSQLite
#else
    #if SWIFT_PACKAGE
        import CSQLite
    #else
        import SQLite3
    #endif
    import GRDB
#endif

class ValueObservationCountTests: GRDBTestCase {
    func testCount() throws {
        struct T: TableRecord { }
        
        try assertValueObservation(
            ValueObservation.tracking(T.fetchCount),
            records: [0, 1, 1, 2, 3, 2],
            setup: { db in
                try db.execute(sql: "CREATE TABLE t(id INTEGER PRIMARY KEY AUTOINCREMENT)")
        },
            recordedUpdates: { db in
                try db.execute(sql: "INSERT INTO t DEFAULT VALUES")
                try db.execute(sql: "UPDATE t SET id = id")
                try db.execute(sql: "INSERT INTO t DEFAULT VALUES")
                try db.inTransaction {
                    try db.execute(sql: "INSERT INTO t DEFAULT VALUES")
                    try db.execute(sql: "INSERT INTO t DEFAULT VALUES")
                    try db.execute(sql: "DELETE FROM t WHERE id = 1")
                    return .commit
                }
                try db.execute(sql: "DELETE FROM t WHERE id = 2")
        })
    }
    
    func testCountWithRemoveDuplicates() throws {
        struct T: TableRecord { }
        
        try assertValueObservation(
            ValueObservation.tracking(T.fetchCount).removeDuplicates(),
            records: [0, 1, 2, 3, 2],
            setup: { db in
                try db.execute(sql: "CREATE TABLE t(id INTEGER PRIMARY KEY AUTOINCREMENT)")
        },
            recordedUpdates: { db in
                try db.execute(sql: "INSERT INTO t DEFAULT VALUES")
                try db.execute(sql: "UPDATE t SET id = id")
                try db.execute(sql: "INSERT INTO t DEFAULT VALUES")
                try db.inTransaction {
                    try db.execute(sql: "INSERT INTO t DEFAULT VALUES")
                    try db.execute(sql: "INSERT INTO t DEFAULT VALUES")
                    try db.execute(sql: "DELETE FROM t WHERE id = 1")
                    return .commit
                }
                try db.execute(sql: "DELETE FROM t WHERE id = 2")
        })
    }
}