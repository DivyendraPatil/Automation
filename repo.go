package main

import (
	"encoding/base64"
	"fmt"
	"github.com/xanzy/go-gitlab"
	"log"
)

func main() {
	baseNamespaceId := 15

	git, err := gitlab.NewClient("your-token-here", gitlab.WithBaseURL("https://gitlab.cbinsights.com/api/v4/"))
	if err != nil {
		fmt.Printf("error setting base url %v\n", err)
	}

	p := &gitlab.ListGroupProjectsOptions{
		ListOptions: gitlab.ListOptions{
			PerPage: 10,
			Page:    1,
		},
		Archived:                 gitlab.Bool(false),
		IncludeSubgroups:         gitlab.Bool(true),
	}

	for {
		// Get the first page with projects.
		ps, resp, err := git.Groups.ListGroupProjects(baseNamespaceId, p)
		if err != nil {
			log.Fatal(err)
		}

		// List all the projects we've found so far.
		for _, project := range ps {
			gf := &gitlab.GetFileOptions{
				Ref: gitlab.String("master"),
			}
			f, resp2, err := git.RepositoryFiles.GetFile(project.ID, "CODEOWNERS", gf)
			if resp2.StatusCode == 404 {
				fmt.Printf("%s does not have a codeowners file\n", project.NameWithNamespace)
				continue
			}
			if err != nil {
				fmt.Println(err)
			}
			if f != nil {
				data, err := base64.StdEncoding.DecodeString(f.Content)
				if err != nil {
					fmt.Println(err)
					continue
				}
				fmt.Printf("%s\nFile contains: %s\n---------\n", project.NameWithNamespace, data)
			}
		}

		// Exit the loop when we've seen all pages.
		if resp.CurrentPage >= resp.TotalPages {
			break
		}

		// Update the page number to get the next page.
		p.Page = resp.NextPage
	}
}