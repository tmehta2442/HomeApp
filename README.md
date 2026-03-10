# Signy V.03

> A clean, distraction-free open house sign-in app for iPad.

Signy lets real estate agents collect visitor information at open houses — no paper, no clipboards, no fuss. Visitors sign in on the iPad, and hosts can review all sign-ins privately behind a password lock.

---

## Features

- **Simple sign-in form** — visitors enter their name, phone, email, and agent info
- **No autofill or keyboard suggestions** — keeps each visitor's entry clean and private
- **Password-protected host view** — only the host can see submissions
- **Soft delete with undo** — deleted entries move to a "Recently Deleted" bin for 30 days
- **Local file export** — every sign-in is automatically saved to a plain-text file you can share or AirDrop
- **iPad optimised** — works in all orientations, designed for the big screen

---

## How to Use

### For Visitors — Signing In

When a visitor arrives, hand them the iPad. They'll see the sign-in screen:

> 📸 **Screenshot pending** — *Visitor sign-in form showing the Welcome header, Your Information fields (First Name, Last Name, Phone Number, Email Address), the Real Estate Agent toggle, and the Save button.*

1. Fill in **First Name**, **Last Name**, **Phone Number**, and **Email Address**
2. If working with a real estate agent, toggle **"I am currently working with a real estate agent"** — agent name, brokerage, and phone fields will appear

> 📸 **Screenshot pending** — *Sign-in form with the Real Estate Agent section expanded, showing Agent's Full Name, Brokerage / Company, and Agent's Phone Number fields.*

3. Tap **Save** — a confirmation message appears and the form clears for the next visitor

> All fields are optional. A visitor can save with as little or as much information as they choose.

---

### For Hosts — Viewing Sign-Ins

Visitor information is kept private behind a password.

#### Opening the Sign-In List

1. Tap the **clipboard icon** in the top-right corner of the screen
2. A password prompt will appear

> 📸 **Screenshot pending** — *Password prompt sheet showing the lock icon, a secure number entry field, and Cancel / Hint / Unlock buttons.*

3. Enter the password and tap **Unlock**
4. Tap **Hint** if you need a reminder

#### The Sign-Ins List

Once unlocked, all visitor sign-ins are shown in reverse chronological order:

> 📸 **Screenshot pending** — *Sign-ins list showing visitor rows with name, timestamp, phone, email, and agent info. Edit button top-left, trash and Done buttons top-right.*

Each row shows:
- Visitor's full name and timestamp
- Phone number and email (if provided)
- Agent name, brokerage, and agent phone (if they have an agent)

---

### Deleting a Sign-In

There are two ways to delete a visitor entry:

- Tap the **trash icon** on the right of a row
- Or tap **Edit** (top-left) and swipe to delete

Deleted entries are not permanently removed — they move to the **Recently Deleted** bin.

---

### Recently Deleted

If a sign-in was deleted by mistake, it can be recovered within **30 days**.

1. From the sign-ins list, tap the **trash circle** icon in the top-right (only visible when deleted items exist)
2. The Recently Deleted screen shows all deleted entries with when they were deleted and when they will be auto-removed

> 📸 **Screenshot pending** — *Recently Deleted screen showing a deleted visitor entry with "Deleted X minutes ago", auto-removal date, and a Restore button.*

- Tap **Restore** to move the entry back to the active sign-ins list
- Tap **Edit** and swipe to permanently delete an entry immediately

---

### Exported Text File

Every time a visitor saves their information, it is automatically appended to a plain-text file stored on the device:

```
Documents/Home Viewing Sign-Ins.txt
```

**Example entry:**

```
========================================
  HOME VIEWING SIGN-IN
  March 10, 2026 at 2:14 PM
========================================

  Name:     Jane Smith
  Phone:    555-867-5309
  Email:    jane@email.com

  Working with an Agent:
    Agent:     Tom Jones
    Brokerage: Realty Co
    Phone:     555-111-2222
```

You can access this file via the **Files app** on iPad, or share/AirDrop it directly.

> To enable Files access, the app has **File Sharing** enabled — it will appear under the app in the Files app's "On My iPad" section.

---

## Requirements

- iPad running **iOS 17** or later
- Xcode 15+ to build from source

---

## Installation

1. Clone this repository
2. Open `HomeSignIn.xcodeproj` in Xcode
3. Select your iPad as the target device
4. Build and run (`⌘R`)

> No third-party dependencies — pure SwiftUI + UIKit.

---

## Privacy

All data is stored **locally on the device only**. Nothing is sent to any server or third party. Visitor information never leaves the iPad unless you explicitly share the exported text file.

---

## Password

The host password and hint are set in `ContentView.swift` and can be changed there.
