package actions

import (
	"commentapi/models"
	"encoding/json"
	"net/http"
)

func (as *ActionSuite) Test_CommentsResource_List() {
	as.createComment("user1", "Comment #1", "subject1")
	as.createComment("user1", "Comment #2", "subject1")
	as.createComment("user2", "Comment #3", "subject1")
	as.createComment("user2", "Comment #4", "subject1")

	res := as.JSON("/api/v1/comments").Get()
	as.Equal(res.Code, http.StatusOK)

	comments := &models.Comments{}
	as.NoError(json.Unmarshal(res.Body.Bytes(), &comments), "Could not unmarshal json response")
	as.Equal(4, len(*comments))
	as.Contains(res.Body.String(), "\"owner\":\"user2\",\"message\":\"Comment #4\",\"subject\":\"subject1\"")
}

func (as *ActionSuite) Test_CommentsResource_Show() {
	comment := as.createComment("usershow", "Comment Show #1", "subject")

	res := as.JSON("/api/v1/comments/%s", comment.ID).Get()
	as.Equal(http.StatusOK, res.Code)
	as.Contains(res.Body.String(), "Comment Show #1")
}

func (as *ActionSuite) Test_CommentsResource_Create() {
	comment := &models.Comment{
		Owner:   "owner",
		Message: "message",
		Subject: "subject",
	}

	res := as.JSON("/api/v1/comments").Post(comment)
	as.Equal(http.StatusCreated, res.Code)
	as.Contains(res.Body.String(), "\"owner\":\"owner\",\"message\":\"message\",\"subject\":\"subject\"")
}

func (as *ActionSuite) Test_CommentsResource_Update() {
	comment := as.createComment("userupdate", "Comment Update #1", "subject")

	comment.Message = "Revised Message"
	res := as.JSON("/api/v1/comments/%s", comment.ID).Put(comment)
	as.Equal(http.StatusOK, res.Code)
	as.Contains(res.Body.String(), "Revised Message")
}

func (as *ActionSuite) Test_CommentsResource_Destroy() {
	comment := as.createComment("userdelete", "Comment Delete #1", "subject")

	res := as.JSON("/api/v1/comments/%s", comment.ID).Delete()
	as.Equal(http.StatusNoContent, res.Code)

	res = as.JSON("/api/v1/comments/%s", comment.ID).Get()
	as.Equal(http.StatusNotFound, res.Code)
}
