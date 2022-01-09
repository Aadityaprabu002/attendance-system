package classroom

import (
	connections "attsys/connections"
	key "attsys/env"
	"attsys/models"
	"database/sql"
	"encoding/json"
	"fmt"
	"html/template"
	"net/http"
	"strconv"
	"strings"
	"time"

	"github.com/gorilla/mux"
	"github.com/gorilla/sessions"
)

type ClassroomTableData struct {
	Todos []models.Classroom
}
type SessionTableData struct {
	Todos []models.PrettySession
}
type HTMLSession struct {
	SessionExist bool
}

var store = sessions.NewCookieStore([]byte(key.GetSecretKey()))

func CreateOrAppendClassRoom(TeacherId string, Classroom models.Classroom) bool {
	conn := fmt.Sprintf("host = %s port = %d user = %s password = %d dbname = %s sslmode = disable", connections.Host, connections.Port, connections.User, connections.Password, connections.DBname)
	db, err := sql.Open("postgres", conn)
	if err != nil {
		panic("failed to establish connection with sql")
	}
	defer db.Close()
	query := fmt.Sprintf(`insert into classrooms (teacher_id,department_id,course_id)
	values('%s','%s','%s');`, TeacherId, Classroom.DepartmentId, Classroom.CourseId)

	query = strings.TrimSpace(query)
	fmt.Println(query)
	_, err = db.Exec(query)
	if err != nil {
		fmt.Println("Error creating a classroom")
		fmt.Println(err)
		return false
	}
	return true
}

func Dashboard(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "text/html; charset=utf-8")
	session, err := store.Get(r, "teacher")
	if err != nil {
		fmt.Println(err)
	}
	msg := models.Htmlresponse{
		Response: "",
		Status:   0,
	}
	if !session.IsNew {
		if r.Method == "GET" {
			fmt.Println("GET")
			tmp, _ := template.ParseFiles("classroom/frontend/ts/dashboard.html")
			data := ClassroomTableData{
				Todos: GetClassrooms(session.Values["TEACHER_ID"].(string)),
			}
			fmt.Println("list of classrooms:")
			fmt.Print(data)
			tmp.Execute(w, data)

		} else if r.Method == "POST" {
			fmt.Println("POST")
			var params models.Classroom
			err := json.NewDecoder(r.Body).Decode(&params)
			if err != nil {
				fmt.Println(err)
			}
			if CreateOrAppendClassRoom(session.Values["TEACHER_ID"].(string), params) {
				msg.Status = 1
			} else {
				msg.Response = "Failed creating a classroom"
			}
			json.NewEncoder(w).Encode(msg)
		}
		return
	} else {
		http.Redirect(w, r, "/teacher/signin", http.StatusSeeOther)
	}

}

func ClassroomDashboard(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "text/html; charset=utf-8")
	session, err := store.Get(r, "teacher")
	if err != nil {
		fmt.Println(err)
	}

	if !session.IsNew {
		if r.Method == "GET" {
			fmt.Println("GET")
			tmp, _ := template.ParseFiles("classroom/frontend/ts/classroomdashboard.html")
			params := mux.Vars(r)
			ClassroomId, _ := strconv.Atoi(params["ClassroomId"])

			listOfSessions := getSessions(ClassroomId)

			var temp models.PrettySession

			var listOfPrettySessions []models.PrettySession

			for _, v := range listOfSessions {
				temp.SessionId = v.SessionId
				temp.Date = v.Date.Format("2006-01-02")
				temp.Start_time = v.Start_time.Format("15:04:05")
				temp.End_time = v.End_time.Format("15:04:05")
				temp.Status = v.Status
				listOfPrettySessions = append(listOfPrettySessions, temp)
			}

			data := SessionTableData{
				Todos: listOfPrettySessions,
			}
			tmp.Execute(w, data)

			// if sessionExist {
			// 	http.Redirect(w, r, "/teacher/dashboard/sessionDetails/", http.StatusSeeOther)
			// } else {
			// 	session.Values["ACTIVE_CLASSROOM"] = ClassroomId
			// 	session.Save(r, w)
			// 	f := HTMLSession{SessionExist: sessionExist}
			// 	tmp.Execute(w, f)
			// }
		} else if r.Method == "POST" {
			fmt.Println("POST")
			msg := models.Htmlresponse{
				Status:   0,
				Response: "",
			}
			fmt.Println(session.Values["ACTIVE_CLASSROOM"].(int))
			var params models.Session
			err := json.NewDecoder(r.Body).Decode(&params)
			params.ClassroomId = session.Values["ACTIVE_CLASSROOM"].(int)
			fmt.Println(params)

			if err != nil {
				fmt.Println("Error obtaining post values!")
				fmt.Println(err)
			}
			if params.Start_time.After(params.End_time) {
				msg.Response = "Start time greater than end time!"
			} else if params.End_time.Sub(params.Start_time) > time.Duration(4)*time.Hour {
				msg.Response = "Session time greater than 4 hours!"
			} else {
				status, sid := createUnqiueSession(params)
				if status {
					session.Values["ACTIVE_SESSION"] = sid
					session.Save(r, w)
					msg.Status = 1 // java script redirect

				} else {
					msg.Response = "Error creating session!"
				}
			}
			json.NewEncoder(w).Encode(msg)
		}
	} else {
		http.Redirect(w, r, "/teacher/signin", http.StatusSeeOther)
	}

}

func SessionDashboard(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "text/html; charset=utf-8")
	session, err := store.Get(r, "teacher")
	if err != nil {
		fmt.Println(err)
	}
	if !session.IsNew {
		if r.Method == "GET" {
			fmt.Println("GET")
			tmp, _ := template.ParseFiles("classroom/frontend/ts/sessionDetails.html")
			classroomid := fmt.Sprintf("%d", session.Values["ACTIVE_CLASSROOM"].(int))
			res := models.Htmlresponse{
				Response: classroomid,
			}
			tmp.Execute(w, res)
		} else if r.Method == "POST" {
			fmt.Println("POST")
		}
	}
}
