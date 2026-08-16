<!-- ================= HEADER ================= -->

<p align="center">
  <img
    src="https://capsule-render.vercel.app/api?type=waving&color=0:0F2027,50:203A43,100:2C5364&height=220&section=header&text=Pilot%20Repair&fontSize=50&fontColor=ffffff&animation=fadeIn&fontAlignY=40&desc=Full-Stack%20Smartphone%20Repair%20Service%20Platform&descAlignY=60&descSize=18"
    width="100%"
  />
</p>

<p align="center">
  <img
    src="https://readme-typing-svg.demolab.com?font=Fira+Code&weight=600&size=20&duration=3000&pause=1000&color=38BDF8&center=true&vCenter=true&width=700&lines=Flutter+Mobile+Application;Flutter+Web+Admin+Dashboard;Dart+Frog+REST+API;PostgreSQL+Database"
    alt="Typing SVG"
  />
</p>

<p align="center">
  <a href="https://github.com/Arif-AD/Pilot_Repair">
    <img src="https://img.shields.io/badge/GitHub-Repository-181717?style=for-the-badge&logo=github&logoColor=white" />
  </a>
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" />
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" />
  <img src="https://img.shields.io/badge/PostgreSQL-4169E1?style=for-the-badge&logo=postgresql&logoColor=white" />
</p>

---

## About the Project

**Pilot Repair** is a full-stack smartphone repair service platform designed to simplify and streamline the smartphone repair process.

The platform consists of:

- **Customer Mobile Application** built with Flutter
- **Admin Web Dashboard** built with Flutter Web
- **RESTful API** built with Dart Frog
- **PostgreSQL** as the primary database

The system connects customers, technicians, and administrators through an integrated digital platform.

---

## Project Preview

<p align="center">
  <img
    src="https://github.com/Arif-AD/Pilot_Repair/blob/main/screenshots/pilorepair1.png?raw=true"
    alt="Pilot Repair Preview"
    width="90%"
  />
</p>

---

## Features

### Customer Mobile Application

| Feature | Description |
|---|---|
| Authentication | Login & Register |
| Profile | Edit and manage user profile |
| Service Location | Select repair service location |
| Repair Booking | Create smartphone repair requests |
| Technician | Find the nearest available technician |
| Order Tracking | Track repair order status |
| Order Management | Create, view, update, and delete orders |
| Real-time Chat | Communication between customer and technician |

---

### Admin Web Dashboard

| Feature | Description |
|---|---|
| Dashboard | Overview of system activity |
| User Management | Manage customer accounts |
| Technician Management | Manage technician accounts |
| Service Management | Manage available repair services |
| Order Management | Manage customer repair orders |
| Repair Monitoring | Monitor repair status and progress |

---

## Tech Stack

### Frontend & Mobile

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" />
</p>

### Backend

<p align="center">
  <img src="https://img.shields.io/badge/Dart_Frog-0175C2?style=for-the-badge&logo=dart&logoColor=white" />
  <img src="https://img.shields.io/badge/RESTful_API-38BDF8?style=for-the-badge&logo=fastapi&logoColor=white" />
</p>

### Database & Services

<p align="center">
  <img src="https://img.shields.io/badge/PostgreSQL-4169E1?style=for-the-badge&logo=postgresql&logoColor=white" />
  <img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" />
</p>

### Tools

<p align="center">
  <img src="https://img.shields.io/badge/Git-F05032?style=for-the-badge&logo=git&logoColor=white" />
  <img src="https://img.shields.io/badge/GitHub-181717?style=for-the-badge&logo=github&logoColor=white" />
</p>

---

## Architecture

```text
┌───────────────────────────┐
│     Flutter Mobile App    │
│         Customer          │
└─────────────┬─────────────┘
              │
              │ REST API
              ▼
┌───────────────────────────┐
│       Dart Frog API       │
│          Backend          │
└─────────────┬─────────────┘
              │
              ▼
┌───────────────────────────┐
│        PostgreSQL         │
│          Database         │
└─────────────▲─────────────┘
              │
              │ REST API
              │
┌─────────────┴─────────────┐
│     Flutter Web Admin     │
│         Dashboard         │
└───────────────────────────┘
