# Database Management Modules

## Overview

UNS-ClaudeJP 3.0 includes two comprehensive database management modules that provide different levels of control over your PostgreSQL database.

## Modules

### 1. DateBaseJP - Integrated Database Management

**Location**: `frontend/src/pages/DateBaseJP.tsx`  
**Route**: `/database`  
**Access**: Menu → DateBaseJP (after 申請管理)

**Features**:
- Visualize all database tables with row counts and column information
- Direct cell editing (click to edit)
- Real-time search across all columns
- Import/Export data (CSV, Excel)
- Delete individual rows with confirmation
- Pagination (20 records per page)
- Modern UI integrated with the application

**Use Cases**:
- Quick data viewing and editing
- Simple data imports/exports
- Everyday database operations
- User-friendly database management

**Security**:
- Admin-only access
- Validated table and column names
- SQL injection protection
- Safe data handling

### 2. Adminer DBJP - Advanced Database Administration

**Location**: `frontend/src/pages/AdminerDBJP.tsx`  
**Route**: `/adminer`  
**Access**: Menu → Adminer DBJP (after DateBaseJP)

**Features**:
- Full Adminer interface integration
- One-click Adminer access with auto-login
- Connection information with copy buttons
- Connection status monitoring
- Detailed usage instructions
- Security warnings
- Complete Adminer feature list

**Adminer Capabilities**:
- Execute custom SQL queries
- Create, modify, and drop tables
- Import/Export in multiple formats (SQL, CSV, etc.)
- Create and manage databases
- Manage database users
- Database backup and restore

**Use Cases**:
- Advanced database operations
- Custom SQL queries
- Database structure management
- Bulk data operations
- Database administration

## Database Connection Information

| Parameter | Value |
|-----------|-------|
| Server | db |
| Port | 5432 |
| Username | uns_admin |
| Password | 57UD10R |
| Database | uns_claudejp |
| Adminer URL | localhost:8080 |

## API Endpoints

### Database Management API
**Base Path**: `/api/database`

| Method | Endpoint | Description | Access |
|--------|----------|-------------|--------|
| GET | `/tables` | Get all tables with info | Admin |
| GET | `/tables/{table_name}/data` | Get table data with pagination | Admin |
| GET | `/tables/{table_name}/export` | Export table as CSV | Admin |
| POST | `/tables/{table_name}/import` | Import data to table | Admin |
| PUT | `/tables/{table_name}/rows/{row_id}` | Update table row | Admin |
| DELETE | `/tables/{table_name}/rows/{row_id}` | Delete table row | Admin |
| POST | `/tables/{table_name}/create` | Create new table | Admin |

## Security Considerations

### General Security
- Both modules require admin role authentication
- All operations are logged
- Input validation and sanitization
- SQL injection protection

### DateBaseJP Security
- Limited to basic CRUD operations
- Cannot modify database structure
- Safe for regular users with admin privileges

### Adminer DBJP Security
⚠️ **Warning**: Adminer is a powerful tool that can make destructive changes
- Can modify database structure
- Can execute arbitrary SQL
- Can delete critical data
- Should be used carefully by experienced administrators

### Best Practices
1. Always create backups before making structural changes
- Use DateBaseJP for routine operations
- Reserve Adminer DBJP for advanced tasks
- Never modify system tables
- Test custom SQL queries on non-production data first

## File Structure

```
frontend/src/
├── pages/
│   ├── DateBaseJP.tsx          # Integrated database management
│   └── AdminerDBJP.tsx         # Adminer interface
├── styles/
│   ├── DateBaseJP.css          # Styles for DateBaseJP
│   └── AdminerDBJP.css         # Styles for AdminerDBJP
└── context/
    └── PageVisibilityContext.tsx # Updated with new page keys

backend/app/api/
└── database.py                 # Database management API endpoints
```

## Usage Examples

### DateBaseJP Usage
1. Navigate to Menu → DateBaseJP
2. Click on a table to view its data
3. Use the search bar to filter results
4. Click on any cell to edit its value
5. Use Import/Export buttons for data transfer

### Adminer DBJP Usage
1. Navigate to Menu → Adminer DBJP
2. Click "Adminerを開く" to open Adminer in a new tab
3. Or manually connect using the provided credentials
4. Execute SQL queries or use the visual interface
5. Use the Import/Export features for bulk operations

## Troubleshooting

### Common Issues

**Adminer not accessible**
- Check if Docker containers are running: `docker-compose ps`
- Restart containers: `docker-compose restart`
- Verify Adminer container is running: `docker logs uns-claudejp-adminer`

**Permission errors**
- Ensure you're logged in as admin user
- Check user role in the database
- Logout and login again if needed

**Data not showing**
- Check database connection
- Verify table exists
- Check if table has data

**Import/Export failures**
- Verify file format (CSV, Excel)
- Check file size limits
- Ensure required columns exist

## Development Notes

### Adding New Features

To extend the database management modules:

1. **DateBaseJP**: Add new API endpoints in `backend/app/api/database.py`
2. **Adminer DBJP**: Update the connection parameters or add more helper functions
3. **Styling**: Modify the respective CSS files
4. **Permissions**: Update the auth checks in the API endpoints

### Testing

Both modules should be tested in a development environment before production use:
- Test with different data types
- Test import/export with various file formats
- Test permissions and access controls
- Test error handling and edge cases

## Future Enhancements

Potential improvements for future versions:
- Database backup scheduling
- Query history and saved queries
- Advanced data visualization
- Real-time data synchronization
- Database performance monitoring
- Automated data validation