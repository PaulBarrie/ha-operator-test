package main

import (
	"fmt"
	"github.com/gin-gonic/gin"
	"log"
	"math/rand"
	"net/http"
	"os"
	"strconv"
	"strings"
)

const serverListSeparator = "_"

func main() {
	r := gin.Default()
	r.GET("/ping", func(c *gin.Context) {
		redirectionProbability, err := strconv.ParseFloat(os.Getenv("REDIRECTION_PROBABILITY"), 64)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{
				"message": "An error occured while reading REDIRECTION_PROBABILITY.",
			})
			return
		}
		if rand.Float64() < redirectionProbability {
			callRandomApp(c)
		}

		c.JSON(http.StatusOK, gin.H{
			"message": "pong",
		})
	})
	r.GET("/internal/ready", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"message": "ok",
		})
	})

	err := r.Run(fmt.Sprintf(":%s", os.Getenv("PORT")))
	if err != nil {
		return
	}

}

func callRandomApp(c *gin.Context) {
	servers := os.Getenv("HOST_LIST")
	log.Default().Println("HOST_LIST: ", servers)
	serverList := strings.Split(servers, serverListSeparator)
	server := serverList[rand.Intn(len(serverList))]
	log.Default().Println("Calling server: ", server)
	_, err := http.Get(fmt.Sprintf("http://%s/ping", server))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"message": fmt.Sprintf("An error occured requesting server %s.", server),
		})
	}
}
