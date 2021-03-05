import csnd
import CsoundVST
from OpenGL.GL import *
from OpenGL.GLUT import *
from OpenGL.GLU import *
import sys

cs = csnd.Csound()

csound.setOrchestra('''
sr=44100
ksmps=100
nchnls=2

instr 1
k1 randomi  20,400,1
a1 oscil 10000,k1,1
a2 oscil a1,100,1
outs  a2,a2

endin
 ''')



csound.setScore('''
            f1 0 8192 10 1
            i1 0 16
            e
            ''')
 

csound.setCommand('csound -h -d -r 44100 -k 441 -m128 -b4096 -B100 -odac8 test.orc test.sco')
csound.exportForPerformance()
csound.compile()
performanceThread = csnd.CsoundPerformanceThread(csound)
performanceThread.Play()

ESCAPE = '\033'

# Number of the glut window.
window = 0

# A general OpenGL initialization function.  Sets all of the initial parameters. 
def InitGL(Width, Height): # We call this right after our OpenGL window is created.
    glClearColor(0.0, 0.0, 0.0, 0.0) # This Will Clear The Background Color To Black
    glClearDepth(1.0) # Enables Clearing Of The Depth Buffer
    glDepthFunc(GL_LESS) # The Type Of Depth Test To Do
    glEnable(GL_DEPTH_TEST) # Enables Depth Testing
    glShadeModel(GL_SMOOTH) # Enables Smooth Color Shading

    glMatrixMode(GL_PROJECTION)
    glLoadIdentity() # Reset The Projection Matrix
# Calculate The Aspect Ratio Of The Window
    gluPerspective(45.0, float(Width)/float(Height), 0.1, 100.0)

    glMatrixMode(GL_MODELVIEW)

# The function called when our window is resized (which shouldn't happen if you enable fullscreen, below)
def ReSizeGLScene(Width, Height):
    if Height == 0: # Prevent A Divide By Zero If The Window Is Too Small 
        Height = 1

    glViewport(0, 0, Width, Height) # Reset The Current Viewport And Perspective Transformation
    glMatrixMode(GL_PROJECTION)
    glLoadIdentity()
    gluPerspective(45.0, float(Width)/float(Height), 0.1, 100.0)
    glMatrixMode(GL_MODELVIEW)

# The main drawing function. 
def DrawGLScene():
    # Clear The Screen And The Depth Buffer
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
    glLoadIdentity() # Reset The View 

    # Move Left 1.5 units and into the screen 6.0 units.
    glTranslatef(-1.5, 0.0, -6.0)

    # Draw a triangle
    glBegin(GL_POLYGON)                 # Start drawing a polygon
    glVertex3f(0.0, 1.0, 0.0)           # Top
    glVertex3f(1.0, -1.0, 0.0)          # Bottom Right
    glVertex3f(-1.0, -1.0, 0.0)         # Bottom Left
    glEnd()                             # We are done with the polygon


    # Move Right 3.0 units.
    glTranslatef(3.0, 0.0, 0.0)

    # Draw a square (quadrilateral)
    glBegin(GL_QUADS)                   # Start drawing a 4 sided polygon
    glVertex3f(-1.0, 1.0, 0.0)          # Top Left
    glVertex3f(1.0, 1.0, 0.0)           # Top Right
    glVertex3f(1.0, -1.0, 0.0)          # Bottom Right
    glVertex3f(-1.0, -1.0, 0.0)         # Bottom Left
    glEnd()                             # We are done with the polygon

    #  since this is double buffered, swap the buffers to display what just got drawn. 
    glutSwapBuffers()

def keyPressed(*args):

    if args[0] == ESCAPE:
        glutDestroyWindow(window)
        sys.exit()

def main():
    global window
    glutInit(())
    glutInitDisplayMode(GLUT_RGBA | GLUT_DOUBLE | GLUT_ALPHA | GLUT_DEPTH)
    glutInitWindowSize(640, 480)
    glutInitWindowPosition(0, 0)
    window = glutCreateWindow("Opengl-csound test")
    glutDisplayFunc (DrawGLScene)
    #glutFullScreen()
    glutIdleFunc(DrawGLScene)
    glutReshapeFunc (ReSizeGLScene)
    glutKeyboardFunc (keyPressed)
    InitGL(640, 480)
    glutMainLoop()

main()
