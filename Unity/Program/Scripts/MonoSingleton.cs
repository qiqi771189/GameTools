/***********************************************************************************************
 ***                                        Mono单例                                         ***
 ***********************************************************************************************
 *                 功能 : 构建可以挂载在UnityObject上的单例，以处理全局业务                    *
 *---------------------------------------------------------------------------------------------*
 * Functions:                                                                                  *
 *   Awake -- 用于构造及保持单例性格,子类勿使用及重写　                                        *
 *   OnStart -- 初始化处理.                                                                    *
 * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

using UnityEngine;

public abstract class MonoSingleton<T> : MonoBehaviour where T : MonoBehaviour
{
    public bool global = true;
    static T instance;
    public static T Instance
    {
        get
        {
            if (instance == null)
            {
                instance =(T)FindObjectOfType<T>();
            }
            return instance;
        }

    }

    void Awake()
    {    
        Debug.LogWarningFormat("{0}[{1}] Awake", typeof(T), this.GetInstanceID());
        if (global)
        {
            if(instance!=null && instance!= this.gameObject.GetComponent<T>())
            {
                Destroy(this.gameObject);
                return;
            }
            DontDestroyOnLoad(this.gameObject);
            instance = this.gameObject.GetComponent<T>();
        }
        this.OnStart();
    }

    protected virtual void OnStart()
    {

    }
}