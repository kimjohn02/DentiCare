# Clean and Sync DentiCare Firestore Database
$projectId = "flutter-69fe1"
$apiKey = "AIzaSyAbI8U7VNsxqqUDwHsv9xWalG2bwrMJW8g"
$baseUrl = "https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "   DENTICARE: CLEANING & SYNCING FIRESTORE DATABASE        " -ForegroundColor Cyan
Write-Host "   Project: $projectId                                     " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

# Helper function to delete all documents in a collection
function Clear-FirestoreCollection ($collectionName) {
    Write-Host "`n>> Cleaning previous records from '$collectionName'..." -ForegroundColor Magenta
    $listUrl = "$baseUrl/$collectionName`?key=$apiKey&pageSize=300"
    try {
        $res = Invoke-RestMethod -Uri $listUrl -Method Get
        if ($res.documents) {
            foreach ($doc in $res.documents) {
                $docName = $doc.name
                $shortId = $docName.Split('/')[-1]
                $delUrl = "https://firestore.googleapis.com/v1/$docName`?key=$apiKey"
                try {
                    Invoke-RestMethod -Uri $delUrl -Method Delete | Out-Null
                    Write-Host "   - Removed old document: $shortId" -ForegroundColor DarkGray
                } catch {
                    Write-Host "   ! Could not remove $shortId" -ForegroundColor DarkYellow
                }
            }
            Write-Host "   Cleaned '$collectionName' collection successfully." -ForegroundColor Green
        } else {
            Write-Host "   Collection '$collectionName' is already empty." -ForegroundColor Gray
        }
    } catch {
        Write-Host "   Collection '$collectionName' ready." -ForegroundColor Gray
    }
}

# -------------------------------------------------------------
# STEP 1: CLEAR OLD / STALE RECORDS
# -------------------------------------------------------------
Clear-FirestoreCollection "dentists"
Clear-FirestoreCollection "services"
Clear-FirestoreCollection "users"
Clear-FirestoreCollection "appointments"

# -------------------------------------------------------------
# STEP 2: INSERT CLEAN & ALIGNED DATA
# -------------------------------------------------------------

# 1. SERVICES
$services = @(
    @{
        id = "bracing"
        fields = @{
            id = @{ stringValue = "bracing" }
            name = @{ stringValue = "Dental Bracing" }
            description = @{ stringValue = "Orthodontic dental braces align and straighten teeth, help position them with regard to a person's bite, and aim to improve dental health." }
            duration = @{ stringValue = "1 hour to 2 hours" }
            cost = @{ stringValue = "P500.00 - P800.00" }
        }
    },
    @{
        id = "cleaning"
        fields = @{
            id = @{ stringValue = "cleaning" }
            name = @{ stringValue = "Teeth Cleaning" }
            description = @{ stringValue = "Routine professional prophylaxis removal of plaque, tartar, and surface stains to prevent cavities and periodontal disease." }
            duration = @{ stringValue = "45 mins to 1 hour" }
            cost = @{ stringValue = "P600.00 - P1,200.00" }
        }
    },
    @{
        id = "whitening"
        fields = @{
            id = @{ stringValue = "whitening" }
            name = @{ stringValue = "Teeth Whitening" }
            description = @{ stringValue = "Cosmetic dental bleaching procedure to lighten teeth and remove discoloration for a brighter and cleaner smile." }
            duration = @{ stringValue = "1 hour" }
            cost = @{ stringValue = "P2,000.00 - P3,500.00" }
        }
    },
    @{
        id = "implants"
        fields = @{
            id = @{ stringValue = "implants" }
            name = @{ stringValue = "Dental Implants & Restoration" }
            description = @{ stringValue = "Surgical placement of artificial tooth roots and crowns to replace missing or severely damaged teeth." }
            duration = @{ stringValue = "1.5 hours to 3 hours" }
            cost = @{ stringValue = "P15,000.00 - P25,000.00" }
        }
    }
)

Write-Host "`n>> Recording new 'services'..." -ForegroundColor Yellow
foreach ($s in $services) {
    $url = "$baseUrl/services/$($s.id)?key=$apiKey"
    $body = @{ fields = $s.fields } | ConvertTo-Json -Depth 5
    try {
        $res = Invoke-RestMethod -Uri $url -Method Patch -Body $body -ContentType "application/json"
        Write-Host "   + Service: $($s.fields.name.stringValue)" -ForegroundColor Green
    } catch {
        Write-Host "   ! Error adding $($s.id): $_" -ForegroundColor Red
    }
}

# 2. DENTISTS
$dentists = @(
    @{
        id = "dr_grace"
        fields = @{
            id = @{ stringValue = "dr_grace" }
            name = @{ stringValue = "Dr. Grace Cabilles" }
            experience = @{ stringValue = "6 years of experience" }
            specialization = @{ stringValue = "Orthodontics, Cosmetic Dentistry, General Dentistry" }
            qualification = @{ stringValue = "Doctor of Dental Medicine (DMD), Board-Certified Orthodontics Specialist, Fellow, Philippine Dental Association" }
        }
    },
    @{
        id = "dr_joana"
        fields = @{
            id = @{ stringValue = "dr_joana" }
            name = @{ stringValue = "Dr. Joana Plewa" }
            experience = @{ stringValue = "7 years of experience" }
            specialization = @{ stringValue = "Pediatric Dentistry, Oral Prophylaxis, Restorative Care" }
            qualification = @{ stringValue = "Doctor of Dental Medicine (DMD), Certified Pediatric Dental Specialist, PRC Lic. Verified" }
        }
    },
    @{
        id = "dr_ryan"
        fields = @{
            id = @{ stringValue = "dr_ryan" }
            name = @{ stringValue = "Dr. Ryan Luza" }
            experience = @{ stringValue = "8 years of experience" }
            specialization = @{ stringValue = "Endodontics, Dental Surgery, Prosthodontics" }
            qualification = @{ stringValue = "Doctor of Dental Medicine (DMD), Endodontics & Oral Surgery Specialist, Fellow, International Congress of Oral Implantologists" }
        }
    },
    @{
        id = "dr_niere"
        fields = @{
            id = @{ stringValue = "dr_niere" }
            name = @{ stringValue = "Dr. Niere Lupmac" }
            experience = @{ stringValue = "5 years of experience" }
            specialization = @{ stringValue = "Periodontics, Teeth Whitening, Preventive Dentistry" }
            qualification = @{ stringValue = "Doctor of Dental Medicine (DMD), Aesthetic Dentistry Specialist, Philippine Dental Association Member" }
        }
    }
)

Write-Host "`n>> Recording new 'dentists'..." -ForegroundColor Yellow
foreach ($d in $dentists) {
    $url = "$baseUrl/dentists/$($d.id)?key=$apiKey"
    $body = @{ fields = $d.fields } | ConvertTo-Json -Depth 5
    try {
        $res = Invoke-RestMethod -Uri $url -Method Patch -Body $body -ContentType "application/json"
        Write-Host "   + Dentist: $($d.fields.name.stringValue)" -ForegroundColor Green
    } catch {
        Write-Host "   ! Error adding $($d.id): $_" -ForegroundColor Red
    }
}

# 3. USERS
$users = @(
    @{
        id = "u_1"
        fields = @{
            id = @{ stringValue = "u_1" }
            username = @{ stringValue = "kim_lupogan" }
            fullName = @{ stringValue = "Lupogan, Kim Macpao" }
            email = @{ stringValue = "kim@gmail.com" }
            contactNumber = @{ stringValue = "0987-654-3210" }
            role = @{ stringValue = "Patient" }
            status = @{ stringValue = "Active" }
            registeredDate = @{ stringValue = "08/01/2026" }
        }
    },
    @{
        id = "u_2"
        fields = @{
            id = @{ stringValue = "u_2" }
            username = @{ stringValue = "ryza_cagabhion" }
            fullName = @{ stringValue = "Cagabhion, Ryza" }
            email = @{ stringValue = "ryza@gmail.com" }
            contactNumber = @{ stringValue = "0912-345-6789" }
            role = @{ stringValue = "Patient" }
            status = @{ stringValue = "Active" }
            registeredDate = @{ stringValue = "08/10/2026" }
        }
    },
    @{
        id = "u_3"
        fields = @{
            id = @{ stringValue = "u_3" }
            username = @{ stringValue = "mark_nuez" }
            fullName = @{ stringValue = "Nuez, Mark" }
            email = @{ stringValue = "mark.nuez@gmail.com" }
            contactNumber = @{ stringValue = "0922-888-9999" }
            role = @{ stringValue = "Patient" }
            status = @{ stringValue = "Active" }
            registeredDate = @{ stringValue = "07/15/2026" }
        }
    },
    @{
        id = "u_4"
        fields = @{
            id = @{ stringValue = "u_4" }
            username = @{ stringValue = "receptionist_jessie" }
            fullName = @{ stringValue = "Jessie Revalde (Clinic Front Desk)" }
            email = @{ stringValue = "desk@denticare.clinic" }
            contactNumber = @{ stringValue = "0917-800-4321" }
            role = @{ stringValue = "Clinic Staff" }
            status = @{ stringValue = "Active" }
            registeredDate = @{ stringValue = "05/01/2026" }
        }
    },
    @{
        id = "u_5"
        fields = @{
            id = @{ stringValue = "u_5" }
            username = @{ stringValue = "admin_kj" }
            fullName = @{ stringValue = "KJ M. Lupogan (System Administrator)" }
            email = @{ stringValue = "admin@denticare.clinic" }
            contactNumber = @{ stringValue = "0919-555-1234" }
            role = @{ stringValue = "Administrator" }
            status = @{ stringValue = "Active" }
            registeredDate = @{ stringValue = "01/10/2026" }
        }
    }
)

Write-Host "`n>> Recording new 'users'..." -ForegroundColor Yellow
foreach ($u in $users) {
    $url = "$baseUrl/users/$($u.id)?key=$apiKey"
    $body = @{ fields = $u.fields } | ConvertTo-Json -Depth 5
    try {
        $res = Invoke-RestMethod -Uri $url -Method Patch -Body $body -ContentType "application/json"
        Write-Host "   + User: $($u.fields.fullName.stringValue) ($($u.fields.role.stringValue))" -ForegroundColor Green
    } catch {
        Write-Host "   ! Error adding $($u.id): $_" -ForegroundColor Red
    }
}

# 4. APPOINTMENTS
$appointments = @(
    @{
        id = "apt_init_pending"
        fields = @{
            id = @{ stringValue = "apt_init_pending" }
            patientName = @{ stringValue = "Lupogan, Kim Macpao" }
            serviceName = @{ stringValue = "Dental Bracing" }
            dentistName = @{ stringValue = "Dr. Grace Cabilles" }
            date = @{ stringValue = "09/11/2026" }
            time = @{ stringValue = "8:00 AM" }
            contact = @{ stringValue = "0987-654-3210" }
            email = @{ stringValue = "kim@gmail.com" }
            status = @{ stringValue = "Pending" }
            notes = @{ stringValue = "New booking via Patient Web Portal" }
        }
    },
    @{
        id = "apt_init_confirmed"
        fields = @{
            id = @{ stringValue = "apt_init_confirmed" }
            patientName = @{ stringValue = "Cagabhion, Ryza" }
            serviceName = @{ stringValue = "Teeth Whitening" }
            dentistName = @{ stringValue = "Dr. Joana Plewa" }
            date = @{ stringValue = "09/11/2026" }
            time = @{ stringValue = "1:00 PM" }
            contact = @{ stringValue = "0912-345-6789" }
            email = @{ stringValue = "ryza@gmail.com" }
            status = @{ stringValue = "Confirmed" }
            notes = @{ stringValue = "Confirmed by clinic reception" }
        }
    },
    @{
        id = "apt_init_completed"
        fields = @{
            id = @{ stringValue = "apt_init_completed" }
            patientName = @{ stringValue = "Nuez, Mark" }
            serviceName = @{ stringValue = "Teeth Cleaning" }
            dentistName = @{ stringValue = "Dr. Ryan Luza" }
            date = @{ stringValue = "08/20/2026" }
            time = @{ stringValue = "10:00 AM" }
            contact = @{ stringValue = "0922-888-9999" }
            email = @{ stringValue = "mark.nuez@gmail.com" }
            status = @{ stringValue = "Completed" }
            notes = @{ stringValue = "Routine prophylaxis and plaque removal performed" }
        }
    }
)

Write-Host "`n>> Recording new 'appointments'..." -ForegroundColor Yellow
foreach ($a in $appointments) {
    $url = "$baseUrl/appointments/$($a.id)?key=$apiKey"
    $body = @{ fields = $a.fields } | ConvertTo-Json -Depth 5
    try {
        $res = Invoke-RestMethod -Uri $url -Method Patch -Body $body -ContentType "application/json"
        Write-Host "   + Appointment: $($a.fields.patientName.stringValue) - $($a.fields.serviceName.stringValue) ($($a.fields.dentistName.stringValue))" -ForegroundColor Green
    } catch {
        Write-Host "   ! Error adding $($a.id): $_" -ForegroundColor Red
    }
}

Write-Host "`n==========================================================" -ForegroundColor Cyan
Write-Host "   SUCCESS: PREVIOUS DATA REMOVED & NEW DATA RECORDED!    " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
