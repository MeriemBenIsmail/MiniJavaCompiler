import tkinter as tk
from tkinter import filedialog
import subprocess

class Compilateur(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title("Dialog")
        self.geometry("499x596")
        
        header = tk.Label(self, text='Mini Java Compiler', font=('Arial', 30,'bold'))
        header.pack(pady=20)
        
        # Importer le fichier source
        self.group_box = tk.LabelFrame(self, text="Importer le fichier source", width=461, height=71)
        self.group_box.place(x=20, y=80)

        self.line_edit = tk.Entry(self.group_box, width=45)
        self.line_edit.place(x=10, y=30)
        
        self.browse_button = tk.Button(self.group_box, text="Parcourir..", command=self.browse_file, bg="blue",fg="white")
        self.browse_button.place(x=360, y=30)

        
        
        # Create the text frame
        text_frame = tk.Frame(self)
        text_frame.pack(side="top", fill="both", expand=True)
        text_frame.place(x=10, y=180)

        # Create the scrollbar widget and pack it inside the frame
        scrollbar = tk.Scrollbar(text_frame)
        scrollbar.pack(side="right", fill="y")

        # Create the text widget and pack it inside the frame
        self.text_edit = tk.Text(text_frame, yscrollcommand=scrollbar.set,height=14)
        self.text_edit.pack(fill="both", expand=True)

        # Link the scrollbar and text widget
        scrollbar.config(command=self.text_edit.yview)

        # Create a Button below the Text widget
        compiler_button = tk.Button(self, text="Compiler", bg="gray", command=self.compiler,width=10)
        compiler_button.place(x=1200, y=150)
        
        # Create a Button below the Text widget
        save_button = tk.Button(self, text="save", bg="blue",fg="white", command=self.save,width=10)
        save_button.place(x=1100, y=150)
        
        # Zone de message
        self.plain_text_edit = tk.Text(self, width=150, height=13, bg="black", fg="green",font=20)
        self.plain_text_edit.place(x=10, y=450)
        
        
           

    
    def browse_file(self):
        filename = filedialog.askopenfilename()
        self.line_edit.delete(0, tk.END)
        self.line_edit.insert(0, filename)
        # Open the file and insert its contents into the text widget
        with open(filename, "r") as f:
            file_contents = f.read()
            self.text_edit.insert(tk.END, file_contents)
            
    def save(self):
        filename = self.line_edit.get()
        content = self.text_edit.get("1.0", "end")
        with open(filename, "w") as f:
            f.write(content)
        self.plain_text_edit.delete('1.0', 'end')
        
       
                    
    def compiler(self):
        filename = self.line_edit.get()
        cmd = ["app.exe"]
        with open(filename, "r") as f:
            result = subprocess.run(cmd, stdin=f, capture_output=True, text=True)
            self.plain_text_edit.insert(tk.END, result)
        
        
            
if __name__ == "__main__":
    app = Compilateur()
    app.mainloop()
