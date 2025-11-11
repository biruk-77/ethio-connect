// Decode JWT tokens to see user IDs
const jwt = require('jsonwebtoken');

const token1 = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjA5YTA4YTVkLWZkMzYtNDZjMC04OTc0LThjZTg0ODk5MzFmOSIsInVzZXJuYW1lIjoidGlnaXN0IiwiZW1haWwiOiJ0aWdpc3RAZ21haWwuY29tIiwicGhvbmUiOiIrMjUxOTEzMTMxMzEzIiwiYXV0aFByb3ZpZGVyIjoicGFzc3dvcmQiLCJpc1ZlcmlmaWVkIjpmYWxzZSwic3RhdHVzIjoiYWN0aXZlIiwicm9sZXMiOlsiZW1wbG95ZWUiXSwicHJvZmlsZSI6eyJmdWxsTmFtZSI6bnVsbCwicHJvZmVzc2lvbiI6bnVsbCwidmVyaWZpY2F0aW9uU3RhdHVzIjoibm9uZSIsInBob3RvVXJsIjpudWxsLCJiaW8iOm51bGx9LCJpYXQiOjE3NjIzNTI2MTgsImV4cCI6MTc2MjM1MzUxOH0.ppgJSIkRBgxQvGck0b0id7U5ExwdZuP9pSrKTExXZ3c';

const token2 = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6ImJhOThhZTFjLTg2YzktNGY5ZS1iOWQ2LTQ1MjE2NzMzNDQ4OSIsInVzZXJuYW1lIjoiYWJlbCIsImVtYWlsIjoiYWJlbEBnbWFpbC5jb20iLCJwaG9uZSI6IisyNTE5MTExMTExMTEiLCJhdXRoUHJvdmlkZXIiOiJwYXNzd29yZCIsImlzVmVyaWZpZWQiOmZhbHNlLCJzdGF0dXMiOiJhY3RpdmUiLCJyb2xlcyI6WyJkb2N0b3IiXSwicHJvZmlsZSI6eyJmdWxsTmFtZSI6IkpvaG4gRG9lIiwicHJvZmVzc2lvbiI6IlNvZnR3YXJlIERldmVsb3BlciIsInZlcmlmaWNhdGlvblN0YXR1cyI6InByb2Zlc3Npb25hbCIsInBob3RvVXJsIjpudWxsLCJiaW8iOiJTb2Z0d2FyZSBFbmdpbmVlciB3aXRoIDUgeWVhcnMgZXhwZXJpZW5jZSJ9LCJpYXQiOjE3NjIzNTIwMzYsImV4cCI6MTc2MjM1MjkzNn0.XRwc5vqwD3-I9MrXuRgowtQ1wTvY5PdtuWLm27cR9L4';

console.log('\n🔍 Token 1 (tigist):');
const decoded1 = jwt.decode(token1);
console.log('  Firebase UID:', decoded1.id);
console.log('  Username:', decoded1.username);
console.log('  Email:', decoded1.email);

console.log('\n🔍 Token 2 (abel):');
const decoded2 = jwt.decode(token2);
console.log('  Firebase UID:', decoded2.id);
console.log('  Username:', decoded2.username);
console.log('  Email:', decoded2.email);

console.log('\n📊 Summary:');
console.log('  Same user?', decoded1.id === decoded2.id ? '❌ YES (PROBLEM!)' : '✅ NO');
