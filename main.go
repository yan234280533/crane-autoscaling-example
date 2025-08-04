package main

import (
	"context"
	"fmt"
	"log"
	"path/filepath"

	cranev1beta1 "github.com/gocrane/api/autoscaling/v1alpha1"
	craneclientset "github.com/gocrane/api/pkg/generated/clientset/versioned"
	craneinformers "github.com/gocrane/api/pkg/generated/informers/externalversions"

	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/client-go/kubernetes/scheme"
	"k8s.io/client-go/rest"
	"k8s.io/client-go/tools/clientcmd"
	"k8s.io/client-go/util/homedir"
)

func main() {
	// 获取kubeconfig配置
	var kubeconfig string
	if home := homedir.HomeDir(); home != "" {
		kubeconfig = filepath.Join(home, ".kube", "config")
	}

	// 创建config
	config, err := clientcmd.BuildConfigFromFlags("", kubeconfig)
	if err != nil {
		// 尝试使用集群内配置
		config, err = rest.InClusterConfig()
		if err != nil {
			log.Fatalf("Error building kubeconfig: %v\n", err)
		}
	}

	// 注册Crane的API
	cranev1beta1.AddToScheme(scheme.Scheme)

	craneClient, err := craneclientset.NewForConfig(config)
	if err != nil {
		log.Fatalf("Error creating crane client: %v\n", err)
		return
	}

	log.Printf("craneclientset created successfully")

	// 获取EHPA列表
	var ehpaList cranev1beta1.EffectiveHorizontalPodAutoscalerList

	craneClient.AutoscalingV1alpha1().RESTClient().Get().
		Resource("effectivehorizontalpodautoscalers").
		Namespace(metav1.NamespaceAll).
		VersionedParams(&metav1.ListOptions{}, scheme.ParameterCodec).
		Do(context.TODO()).
		Into(&ehpaList)
	if err != nil {
		log.Fatalf("Error listing EHPAs: %v\n", err)
	}

	log.Printf("craneclientset get successfully")

	// 打印所有EHPA的名称
	for _, ehpa := range ehpaList.Items {
		fmt.Printf("Found EHPA: %s in namespace %s\n", ehpa.Name, ehpa.Namespace)
	}
}
