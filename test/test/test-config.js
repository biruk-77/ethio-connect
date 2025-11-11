/**
 * Test Configuration
 * Configured with actual tokens and post ID
 */

module.exports = {
    serverUrl: 'https://ethiocms.unitybingo.com',
    
    // User 1 (tigist - buyer/employee)
    buyer: {
        token: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjA5YTA4YTVkLWZkMzYtNDZjMC04OTc0LThjZTg0ODk5MzFmOSIsInVzZXJuYW1lIjoidGlnaXN0IiwiZW1haWwiOiJ0aWdpc3RAZ21haWwuY29tIiwicGhvbmUiOiIrMjUxOTEzMTMxMzEzIiwiYXV0aFByb3ZpZGVyIjoicGFzc3dvcmQiLCJpc1ZlcmlmaWVkIjpmYWxzZSwic3RhdHVzIjoiYWN0aXZlIiwicm9sZXMiOlsiZW1wbG95ZWUiXSwicHJvZmlsZSI6eyJmdWxsTmFtZSI6bnVsbCwicHJvZmVzc2lvbiI6bnVsbCwidmVyaWZpY2F0aW9uU3RhdHVzIjoibm9uZSIsInBob3RvVXJsIjpudWxsLCJiaW8iOm51bGx9LCJpYXQiOjE3NjI0OTY3MDksImV4cCI6MTc2MjU4MzEwOX0.Wax6z-Aqrj1fZQpADy8VrOIYxWRqyViU2xKxytVbAzo',
        username: 'tigist',
        // userId will be auto-filled after authentication
    },
    
    // User 2 (abel - seller/doctor)
    seller: {
        token: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6ImJhOThhZTFjLTg2YzktNGY5ZS1iOWQ2LTQ1MjE2NzMzNDQ4OSIsInVzZXJuYW1lIjoiYWJlbCIsImVtYWlsIjoiYWJlbEBnbWFpbC5jb20iLCJwaG9uZSI6IisyNTE5MTExMTExMTEiLCJhdXRoUHJvdmlkZXIiOiJwYXNzd29yZCIsImlzVmVyaWZpZWQiOmZhbHNlLCJzdGF0dXMiOiJhY3RpdmUiLCJyb2xlcyI6WyJkb2N0b3IiXSwicHJvZmlsZSI6eyJmdWxsTmFtZSI6IkpvaG4gRG9lIiwicHJvZmVzc2lvbiI6IlNvZnR3YXJlIERldmVsb3BlciIsInZlcmlmaWNhdGlvblN0YXR1cyI6InByb2Zlc3Npb25hbCIsInBob3RvVXJsIjpudWxsLCJiaW8iOiJTb2Z0d2FyZSBFbmdpbmVlciB3aXRoIDUgeWVhcnMgZXhwZXJpZW5jZSJ9LCJpYXQiOjE3NjI0OTY2NjMsImV4cCI6MTc2MjU4MzA2M30.liBe-kAbLnplHUL16WjaUyYyamsBkJPiDJaAKxC2-Ak',
        username: 'abel',
        // userId will be auto-filled after authentication
    },
    
    // User 1 config (for other tests)
    user1: {
        token: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjA5YTA4YTVkLWZkMzYtNDZjMC04OTc0LThjZTg0ODk5MzFmOSIsInVzZXJuYW1lIjoidGlnaXN0IiwiZW1haWwiOiJ0aWdpc3RAZ21haWwuY29tIiwicGhvbmUiOiIrMjUxOTEzMTMxMzEzIiwiYXV0aFByb3ZpZGVyIjoicGFzc3dvcmQiLCJpc1ZlcmlmaWVkIjpmYWxzZSwic3RhdHVzIjoiYWN0aXZlIiwicm9sZXMiOlsiZW1wbG95ZWUiXSwicHJvZmlsZSI6eyJmdWxsTmFtZSI6bnVsbCwicHJvZmVzc2lvbiI6bnVsbCwidmVyaWZpY2F0aW9uU3RhdHVzIjoibm9uZSIsInBob3RvVXJsIjpudWxsLCJiaW8iOm51bGx9LCJpYXQiOjE3NjI0OTY3MDksImV4cCI6MTc2MjU4MzEwOX0.Wax6z-Aqrj1fZQpADy8VrOIYxWRqyViU2xKxytVbAzo',
        username: 'tigist',
    },
    
    // User 2 config (for other tests)
    user2: {
        token: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6ImJhOThhZTFjLTg2YzktNGY5ZS1iOWQ2LTQ1MjE2NzMzNDQ4OSIsInVzZXJuYW1lIjoiYWJlbCIsImVtYWlsIjoiYWJlbEBnbWFpbC5jb20iLCJwaG9uZSI6IisyNTE5MTExMTExMTEiLCJhdXRoUHJvdmlkZXIiOiJwYXNzd29yZCIsImlzVmVyaWZpZWQiOmZhbHNlLCJzdGF0dXMiOiJhY3RpdmUiLCJyb2xlcyI6WyJkb2N0b3IiXSwicHJvZmlsZSI6eyJmdWxsTmFtZSI6IkpvaG4gRG9lIiwicHJvZmVzc2lvbiI6IlNvZnR3YXJlIERldmVsb3BlciIsInZlcmlmaWNhdGlvblN0YXR1cyI6InByb2Zlc3Npb25hbCIsInBob3RvVXJsIjpudWxsLCJiaW8iOiJTb2Z0d2FyZSBFbmdpbmVlciB3aXRoIDUgeWVhcnMgZXhwZXJpZW5jZSJ9LCJpYXQiOjE3NjI0OTY2NjMsImV4cCI6MTc2MjU4MzA2M30.liBe-kAbLnplHUL16WjaUyYyamsBkJPiDJaAKxC2-Ak',
        username: 'abel',
    },
    
    // Test Post
    post: {
        id: '903dbbb8-6cd9-4131-b8fe-8cb185b7651c',
        type: 'marketplace'
    }
};
