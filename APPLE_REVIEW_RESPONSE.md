# Apple Review Response - Dr. Parrilla Paraguay

## Submission ID: 03171218-25a1-47a8-9d88-821be032b712

## Response to Guideline Issues

All reported issues have been resolved in this build:

### 1. App Restart Issue - FIXED
The app no longer restarts on launch. We identified and fixed Firebase Realtime Database long-polling URLs (.lp URLs) that were incorrectly triggering WebView navigation. The fix blocks these internal Firebase SDK URLs at multiple points:
- onPageStarted handler
- onNavigationRequest handler  
- External URL handler

### 2. Login Flow - FIXED
Login now requests the phone number only once. The session persists correctly in localStorage and survives app restarts.

### 3. Account Deletion (Guideline 5.1.1v) - IMPLEMENTED
Account deletion feature is now available:
- Location: Profile → Support (Soporte) → "Eliminar mi cuenta"
- Flow: User selects a reason from 5 options, can add optional feedback
- Data: All user data is marked as deleted and local storage is cleared
- Session: User is logged out after deletion

### 4. Safari/iPad Compatibility - VERIFIED
The app renders correctly on all iOS devices including iPad. WebView uses proper viewport settings and handles dynamic content correctly.

### 5. Firebase Sync - OPTIMIZED
Firebase synchronization no longer interferes with app navigation or causes unexpected behavior.

## Demo Account for Testing

- **Phone Number**: 0991123456
- **Password**: (none required)
- **Instructions**: Enter the phone number on the login screen and tap "INGRESAR"

This demo account provides full client experience including:
- Order tracking
- Product catalog browsing
- Support ticket creation
- Account deletion testing

## Technical Details

- **Bundle ID**: com.drparrilla.app
- **Version**: 2.1.3
- **Build**: 163+
- **Platform**: iOS 15.0+

## Contact

For any questions regarding this submission:
- Email: drparrillaparaguay@gmail.com
- Developer: Samuel Garcia Báez
