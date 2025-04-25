**Key Decisions:**

- Memory-Awareness: The backend limits to 50 comments: 
    (Comment.where(is_spam: false).order(created_at: :desc).limit(50)), 
and the frontend enforces this with:
    comments.value.slice(0, 50) and pop() when adding new comments via WebSocket.
- WebSockets: ActionCable is used to push new comments to clients, ensuring real-time updates without polling.


**Prerequisites**
- Ruby 3.2+
- Rails 7.1+
- PostgreSQL (or your preferred database)
- Node.js and npm (for the frontend Vue app)


**Setup Instructions**

**Clone the Repository:**

- git clone <repository-url>
- cd guestbook-backend

**Install Dependencies:**
-bundle install

**Set Up the Database:**
- Ensure your database is running (e.g., PostgreSQL).
- Update config/database.yml with your database credentials if needed.

**Create and migrate the database:**
- rails db:create
- rails db:migrate

**Seed the Admin User:**
- rails db:seed

**Admin credentials:**
- username: admin
- passowrd: password123


**Start the Rails Server:**
- rails s

The backend will be available at http://localhost:3000.



**Set Up the Frontend:**

Navigate to the frontend directory (assuming it’s in a separate folder like guestbook-frontend-app):
- cd ../guestbook-frontend
- npm install
- npm run dev

The frontend will typically be available at http://localhost:5173 or http://localhost:8080 (or another port specified by Vite).
