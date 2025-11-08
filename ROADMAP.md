# A Market - Development Roadmap

## Infrastructure & Setup

- [ ] **Initialize project structure**
   - [ ] Create Astro 5.x project with React 19 islands
   - [ ] Setup TypeScript strict mode
   - [ ] Configure Tailwind CSS 4.x
   - [ ] Add basic folder structure (components, layouts, lib)
   - [ ] Include PWA configuration

- [ ] **Setup Docker development environment**
   - [ ] Create docker-compose.yml with Supabase stack
   - [ ] Configure environment variables
   - [ ] Add development scripts
   - [ ] Test full stack startup

- [ ] **Setup testing framework**
   - [ ] Configure Vitest for unit tests
   - [ ] Configure Playwright for E2E tests
   - [ ] Add basic test structure and sample tests

## Authentication System

- [ ] **Setup Supabase auth configuration**
   - [ ] Configure Supabase project with email/phone OTP
   - [ ] Add Twilio integration for phone auth
   - [ ] Create auth middleware and session handling

- [ ] **Create invite validation system**
   - [ ] Implement invite code generation and validation
   - [ ] Create invites table and basic RLS policies
   - [ ] Add invite usage tracking

- [ ] **Build signup flow**
   - [ ] Create invite code validation page
   - [ ] Implement email/phone OTP verification
   - [ ] Create user record with invited_by relationship
   - [ ] Add contact_info creation with primary contact

- [ ] **Create onboarding wizard**
   - [ ] Build 4-step wizard component
   - [ ] Add account type selection
   - [ ] Implement contact visibility settings
   - [ ] Create about/avatar upload functionality
   - [ ] Add tutorial/walkthrough

- [ ] **Setup protected routes**
   - [ ] Create auth layout wrapper
   - [ ] Implement route protection middleware
   - [ ] Add user session verification

## Core User Management

- [ ] **Implement user profile system**
   - [ ] Create user settings management
   - [ ] Add profile editing functionality
   - [ ] Implement vendor_id uniqueness and profile pages

- [ ] **Build connection system**
   - [ ] Create connection requests functionality
   - [ ] Implement acceptance/decline flows
   - [ ] Add connection status tracking
   - [ ] Create connection list components

## Item Management System

- [ ] **Create category management**
   - [ ] Setup category table with basic categories
   - [ ] Create category selection component
   - [ ] Add category filtering and display

- [ ] **Build item creation flow**
   - [ ] Create item form component
   - [ ] Implement item validation
   - [ ] Add image upload with compression
   - [ ] Create item_image table and relationships

- [ ] **Implement item listing and search**
   - [ ] Create items listing page with filters
   - [ ] Add search functionality
   - [ ] Implement item visibility rules
   - [ ] Create item detail pages
   - [ ] Implement view transition from `ItemCard` to item detail page

- [ ] **Implement watch list**
   - [ ] Allow user to save a search/filter combination for easy access in the future
   - [ ] Allow user to enable weekly notifications for any search in their watch list
   - [ ] Implement CloudFlare worker that goes through each item in the watch list for every user and send notifications that include any new items (added in the past week)

## Messaging System

- [ ] **Create messaging infrastructure**
   - [ ] Setup thread creation logic
   - [ ] Implement message sending/receiving
   - [ ] Add message polling system
   - [ ] Create thread list interface

- [ ] **Build message images support**
   - [ ] Add message_image table and relationships
   - [ ] Implement image upload for messages
   - [ ] Create message composition UI

## UI & Polish

- [ ] **Create main navigation and layouts**
   - [ ] Build header component with navigation
   - [ ] Create dashboard layout
   - [ ] Implement responsive design
   - [ ] Add vendor profile pages

- [ ] **Implement item feed and vendor pages**
   - [ ] Create vendor profile routing (/{vendor_id})
   - [ ] Build item feed with connection prioritization
   - [ ] Add vendor showcase/portfolio display

- [ ] **Add error handling and user feedback**
   - [ ] Implement comprehensive error boundaries
   - [ ] Add loading states and progress indicators
   - [ ] Create user-friendly error messages
   - [ ] Add form validation feedback

## Testing & Quality

- [ ] **Add comprehensive test coverage**
   - [ ] Write unit tests for utilities and components
   - [ ] Create E2E tests for critical user flows
   - [ ] Add authentication flow tests
   - [ ] Test item creation and messaging flows

- [ ] **Security and performance validation**
   - [ ] Verify RLS policies work correctly
   - [ ] Test visibility rules and anonymity
   - [ ] Performance testing for image uploads
   - [ ] Security audit of auth flows

- [ ] **Alpha testing preparation**
   - [ ] Setup monitoring and logging
   - [ ] Create admin tools for user management
   - [ ] Add content moderation basics
   - [ ] Prepare for alpha tester onboarding
