class AssignmentsController < ApplicationController
    before_action :logged_in_user
    before_action :admin_user

    def download
        @assignments = []
        assign = Assignment.all
        i = 1
        data = "SNo, Team, Project Title, Organization, Contact, Description, On Campus, Legacy SW\n"
        assign.each do |a|
            @project = Project.find_by(id: a.project_id)
            @team = Team.find_by(id: a.team_id)
            legacy = if @project.islegacy.to_s == 'true'
                         'Yes'
                     else
                         'No'
                     end
            oncampus = if @project.oncampus.to_s == 'true'
                           'Yes'
                       else
                           'No'
                       end
            data << i.to_s << ',' << @team.name.to_s.inspect << ',' << @project.title << ',' << @project.organization.to_s.inspect << ',' << @project.contact.to_s.inspect << ',' << @project.description.to_s.inspect << ',' << oncampus.to_s << ',' << legacy.to_s << "\n"
            i += 1
        end
        date = Time.now.strftime('%Y%m')
        send_data data, filename: "project-assignment-#{date}.csv"
    end

    def assign
        # Modify this to only pick teams and projects that do not have assignemnts yet

        reserved_teams = Assignment.all.collect(&:team_id)
        reserved_projects = Assignment.all.collect(&:project_id)

        teams = Team.where.not(id: reserved_teams)
        # projects = Project.where("approved = ? AND id NOT IN (?)", true, reserved_projects)

        # Handle admin sad path in case of "no teams created"
        if teams.size < 2
            flash[:danger] = 'Cannot proceed with Assignment Algorithm, less than 2 teams exist.'
            redirect_to viewassign_path
            return
        end

        projects = Project.where.not(id: reserved_projects).where(approved: true).where(isactive: true)

        # Handle admin sad path in case of "too few projects"
        if teams.size > projects.size
            flash[:danger] = 'Cannot proceed with Assignment Algorithm, Number of Unassigned Teams more than number of Approved and available Projects'
            redirect_to viewassign_path
            return
        end

        nums = [teams.size, projects.size].max
        costMatrix = Array.new(nums) {Array.new(nums)}

        numTeams = teams.size
        infiniteCost = nums * projects.size

        # Fill Cost Matrix with cost values
        (0..(teams.size - 1)).each do |i|
            (0..(projects.size - 1)).each do |j|
                pref = Preference.find_by(team_id: teams[i].id, project_id: projects[j].id)
                costMatrix[i][j] = if pref && (pref.value == 1)
                                       1
                                   elsif pref && (pref.value == -1)
                                       (2 * numTeams) + 1
                                   else
                                       numTeams + 1
                                   end
            end
        end

        # Fill in the padded rows with infinite cost value so that they are never assigned any project before others
        (teams.size..(nums - 1)).each do |i|
            (0..(projects.size - 1)).each do |j|
                costMatrix[i][j] = infiniteCost
            end
        end

        # Call Munkres algorithm on the Cost Matrix
        m = Munkres.new(costMatrix)
        pairings = m.find_pairings

        numPos = 0
        numNeu = 0
        numNeg = 0
        # Assignment.delete_all
        (0..(pairings.size - 1)).each do |i|
            pair = pairings[i]
            next unless pair[0] < teams.size

            team = teams[pair[0]]
            project = projects[pair[1]]
            Assignment.create(team_id: team.id, project_id: project.id)
            pref = Preference.find_by(team_id: team.id, project_id: project.id)
            if pref && (pref.value == 1)
                numPos += 1
            elsif pref && (pref.value == -1)
                numNeg += 1
            else
                numNeu += 1
            end
        end
        flash[:success] = 'Assignment algorithm ran successfully, ' + numPos.to_s + ' teams got Positive preference, ' + numNeu.to_s + ' teams got Neutral preference, ' + numNeg.to_s + ' teams got Negative preference'
        redirect_to viewassign_path
    end

    def view
        @team_names = []
        @project_names = []
        Team.find_each do |team|
            @team_names << team.name
        end

        allProjects = Project.where('approved = ?', true)
        allProjects.each do |project|
            @project_names << project.title
        end

        @assignments = []
        assign = Assignment.all
        assign.each do |a|
            @project = Project.find_by(id: a.project_id)
            @team = Team.find_by(id: a.team_id)
            hash = {project_id: @project.id, team_id: @team.id, project_title: @project.title, team_name: @team.name}
            @assignments << hash
        end
    end

    def clearall
        Assignment.delete_all
        redirect_to viewassign_path
    end

    def delete
        @assigned = Assignment.find_by_project_id(params[:project_id])

        if !@assigned.nil?
            @assigned.destroy
            flash[:success] = 'Delete successful'
        else
            flash[:danger] = 'Error! Still processing your previous request'
        end
        redirect_to viewassign_path
    end

    def add
        team = Team.find_by_name(params[:team_name].to_s)
        team_assigned = Assignment.find_by_team_id(team.id)
        project = Project.find_by_title(params[:project_title].to_s)
        project_assigned = Assignment.find_by_project_id(project.id)

        if !team_assigned.nil? || !project_assigned.nil?
            flash[:danger] = 'Team or Project was already assigned'
            redirect_to viewassign_path
            return
        end
        assignment = Assignment.new
        assignment.team_id = Team.find_by_name(params[:team_name].to_s).id
        assignment.project_id = Project.find_by_title(params[:project_title].to_s).id
        assignment.save
        flash[:success] = 'Successfully assigned project ' + params[:project_title].to_s + ' to team ' + params[:team_name].to_s
        redirect_to viewassign_path
    end
end
