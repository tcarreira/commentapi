package actions

import (
	"commentapi/models"
	"testing"

	"github.com/gobuffalo/packr/v2"
	"github.com/gobuffalo/suite"
)

type ActionSuite struct {
	*suite.Action
}

func Test_ActionSuite(t *testing.T) {
	action, err := suite.NewActionWithFixtures(App(), packr.New("Test_ActionSuite", "../fixtures"))
	if err != nil {
		t.Fatal(err)
	}

	as := &ActionSuite{
		Action: action,
	}
	suite.Run(t, as)
}

func (as *ActionSuite) createComment(owner, message, subject string) *models.Comment {
	comment := &models.Comment{
		Owner:   owner,
		Message: message,
		Subject: subject,
	}

	as.NoError(as.DB.Create(comment))
	return comment

}
